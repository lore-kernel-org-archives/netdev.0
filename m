From: Claude Robitaille <clauder@accedian.com>
Subject: sk_buff handling in packet handler
Date: Sat, 16 May 2009 12:31:28 -0400
Message-ID: <4A0EEA60.6090702@accedian.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070600060900000103080402"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:17637 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbZEPQbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 12:31:40 -0400
Received: by qw-out-2122.google.com with SMTP id 5so1967932qwd.37
        for <netdev@vger.kernel.org>; Sat, 16 May 2009 09:31:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070600060900000103080402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

My question is a development question so I hope this is the correct list 
to post it. If not just tell me and I will find another list...

I am developing a packet handler that I register via dev_add_pack. All 
is fine except that after a while the kernel crashes. I suspect my 
handler not doing something correct...

The handler is registered with the ETH_P_ALL list, listening on a 
specific interface.

After many attempt at reducing the scope of what my handler is doing I 
now simply do a return in my handler. When I send lots of frames to 
interface that I am listening to after a while I start getting kernel 
messages about low memory and eventually even get exception dumps.

I suspect that the handler needs to do something with the sk_buff but I 
am not sure what. I printed the content of the sk_buff and found that 
the skb_buff is not cloned (looking on the web I had found that the 
sk_buff should have been cloned) and that he number of users is 1.

Should I simply do a dev_kfree_skb? What are the rules governing the use 
of the sk_buff in a packet handler? Should I clone the sk_buff?

Also, a related question, the packet handler is expected to return an 
int. What should be returned?

Thanks

Claude
 

--------------070600060900000103080402
Content-Type: text/x-vcard; charset=utf-8;
 name="clauder.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="clauder.vcf"

begin:vcard
fn:Claude Robitaille
n:Robitaille;Claude
email;internet:clauder@accedian.com
tel;work:514-764-0119
tel;cell:514-796-7225
x-mozilla-html:TRUE
version:2.1
end:vcard


--------------070600060900000103080402--
