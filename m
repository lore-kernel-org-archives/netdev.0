From: "junk" <junk@toutatis.be>
Subject: Re: skb_clone
Date: Thu, 17 Feb 2005 14:53:11 +0100
Message-ID: <20050217134407.M46105@toutatis.be>
References: <20050217101331.M38167@toutatis.be>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
To: netdev@oss.sgi.com
In-Reply-To: <20050217101331.M38167@toutatis.be>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



>Hello,
>
>i made a clone of a skb i catched with a netfilter hook.
>
>Now i want to send that cloned skb on the wire.. what should i do? I tried
>with dev_queue_xmit without success..


I've been able to transmit my packet.. no more kernel oops but it seems i'm
having an alignment problem. Tcpdump tells me "ethertype unknown" on each
packet that has been altered by my module. That packet originally comes from
"ping", I do not generate it myself, so i guess the ethernet header, IP
header, data are correct. It just seems I missed a point before
dev_queue_xmit() my skb.

I'm having the same problem if I skb_copy() instead of skb_clone() the
original skb.

Here is a summary of my code:

hook_interrupt -> cloning skb to new_skb -> changing new_skb->dev to another
interface -> dev_queue_xmit(new_skb); -> return NF_STOLEN for the original skb

What am I missing?
