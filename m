From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Wed, 06 Apr 2005 21:53:55 +0800
Message-ID: <20050406214848.029A.LARK@linux.net.cn>
References: <20050406123036.GO26731@postel.suug.ch> <4253E5D4.60504@mrv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, hadi@cyberus.ca, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: emann@mrv.com (Eran Mann)
In-Reply-To: <4253E5D4.60504@mrv.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Eran Mann,


On Wed, 06 Apr 2005 16:36:20 +0300, emann@mrv.com (Eran Mann) wrote:


> 
> Maybe you could add to the list of options a XOR of bytes hash, 
> something like:
> static inline u8 bytes_xor_u32( u32 key )
> {
> 	u8 *dummy_array = (u8 *)&key;
> 	u8 hash = dummy_array[0] ^ dummy_array[1] ^
> 		  dummy_array[2] ^ dummy_array[3];
> 
> 	return hash;
> }
> 

Ha, then this hi-or-lo word hash, which assumes that high or low word is
0, and key is distributed in the old fashion (0..255, etc)

static inline u32 hi_or_lo_hash(u32 key)
{
	return (key >> 16 ^ key) & 0xFF;
}


-- 
  lark
