From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 05 Apr 2005 19:25:45 +0800
Message-ID: <20050405190024.024D.LARK@linux.net.cn>
References: <20050405140342.024A.LARK@linux.net.cn> <20050405103827.GL26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050405103827.GL26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,

If you read the thread I pointed to, then you know there is chance that
nfmark is used as two 16 bit numbers (along with CONNMARK), and the 16
bit number can be mapped to a classid. This is one of many chances.

In that case, nfmark can be used like this

0x00010000
0x00020000
0x00030000
...

0x00000001
0x00000002
0x00000003
...

The old hash function doesn't expect such pattern.

I must admit that I am not very familiar with hash function. I find that
and use a quick hack. My patch just points out the existing risk. Anyone
can improve this by using a faster and even distributed hash function.

And actually, for 256 as hash size, the second patch I sent can be still
improved,

    return (jhash_1word(handle, 0xF30A7129) & 0xFF);

instead of

    return (jhash_1word(handle, 0xF30A7129) % 256);


On Tue, 5 Apr 2005 12:38:27 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> * Wang Jian <20050405140342.024A.LARK@linux.net.cn> 2005-04-05 14:05
> > New patch attached. Hashsize is 256, the same as old one.
> 
> Do you have any numbers that could prove that this change
> actually improves the hash distribution and thus the overall
> lookup performance?
> 
> The most often used and thus most important range of mark
> values is definitely 0..255. I did not look into jhash
> but the risk of collisions definitely increases with this
> change which affects about 90% of the users of fw which
> could benefit from a collision free hashtable so far.
> 
> I would appreciate if you could provide some numbers proving
> both the need and actual improvement of this change since
> fwmark is one of the most often used classifiers.
> 
> Cheers



-- 
  lark
