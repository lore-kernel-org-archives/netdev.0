From: Patrick McHardy <kaber@trash.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 01:49:09 +0100
Message-ID: <41F44605.6050001@trash.net>
References: <41F432BD.3000300@davidcoulson.net> <20050124003241.GJ23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Coulson <david@davidcoulson.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050124003241.GJ23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>I CC'ed netdev, this seems more serious than I thought.
>
>Background: David noticed the assertion csum + 2 > offset being trigged
>in skb_checksum_help. I sent him a patch converting it into a warning
>printing offset, len, n.raw, tail, csum, features and the whole packet
>as hexdump. He uses the acenic driver which is actually capable of doing
>IP checksumming. (Patch enclosed at the end)
>
How does the backtrace look ?

>>skb hdr corrupted!
>>
>
The check looks bogus:

>+		if (skb->h.raw < skb->data || skb->h.raw > skb->data)
>+			printk(KERN_CRIT "skb hdr corrupted!\n");
>+		goto out;
>+	}
>
Regards
Patrick
