From: "Memon, Mazhar I" <mimemon@sandia.gov>
Subject: skb_copy() for private linear skb->data
Date: Thu, 27 Jun 2002 10:52:38 -0600
Sender: owner-netdev@oss.sgi.com
Message-ID: <B51F0C636E578A4E832D3958690CD73E0BCA4D7B@es04snlnt>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

According to the comment above skb_copy():
"As by-product this function converts non-linear &sk_buff to linear one, so
that &sk_buff becomes completely private and caller is allowed to modify all
the data of returned buffer. "
So in order to do some sort  of  data transformation on skb->data:
new_skb = skb_copy(skb, GFP_ATOMIC);
encrypt(new_skb->data)
<nuke skb> 			with skb_unlink(skb)?
<send new_skb>		with dev_kfree_skb(new_skb)?
This causes an oops.
Or instead of nuking, and sending, should the list pointers of the two skb's
be swapped so that the new_skb appears in the list where 'skb' once lived,
and then kfree(skb)?  I've tried to find an answer to this simple question
in many places without luck.  Also, I cannot use skb_linearize, since not
all data is made private to the caller.

-Mazhar
