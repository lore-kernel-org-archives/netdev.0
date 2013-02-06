From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Wed, 06 Feb 2013 09:30:08 -0500
Message-ID: <511268F0.5070808@mojatatu.com>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com> <20130205081232.GF23291@secunet.com> <51125744.3030905@gmail.com> <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Romain KUNTZ <r.kuntz@ipflavors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13-02-06 08:53 AM, Emmanuel Thierry wrote:
> Actually, we didn't think about this problem since we work with priorities, putting the default policy (without a mark) at a minor priority than the marked one.

I think priorities are the way to go in cases of ambiguity.

> Your remark makes clearer the ideas behind the design of XFRM, but this leads to an interesting concern. If on policy insertion, the policy were inserted depending on the accuracy of the mark (the more the mask is specific, the more the mark must be put at the beginning of the list), how would we decide which is the more specific between these ones ?
>
> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0x00000001 mask 0x00000005
>
> ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 0x00000001 mask 0x00000003

They look different to me, no? i.e i dont see a conflict - one has 
mark=5 and the other
has mark=3.

cheers,
jamal
