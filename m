From: jamal <hadi@cyberus.ca>
Subject: RFC: XFRM changing the view of xfrm_aevent_id
Date: Fri, 01 Dec 2006 09:37:52 -0500
Message-ID: <1164983872.3562.45.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Krisztian <hidden@balabit.hu>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:42679 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936127AbWLAOh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 09:37:57 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1544473nze
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 06:37:57 -0800 (PST)
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

while trying to patch iproute2 to display the xfrm aevents i came to the
conclusion that the xfrm_aevent_id struct didnt provide enough info
for me to uniquely identify an SA.
I need two other items: the reqid and saddr.

The structure currently looks like

struct xfrm_aevent_id {
        struct xfrm_usersa_id           sa_id;
        __u32                           flags;
};

I could add the two items mentioned above in it and break the ABI.
This may sound dangerous, but the usage of this ABI is not widespread.
AFAIK, the only other person who might have used this is Kristzian (on
CC).

If this is considered evil, then i will transfer the two items in
a new TLV but it wont be as pretty.

Thoughts?

cheers,
jamal

