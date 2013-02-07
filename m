From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Thu, 7 Feb 2013 13:54:37 +0100
Message-ID: <20130207125437.GC17794@secunet.com>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com>
 <20130205081232.GF23291@secunet.com>
 <51125744.3030905@gmail.com>
 <D4563759-CEC5-4F33-BF0A-9FA10716F8DF@telecom-bretagne.eu>
 <20130207104908.GA17794@secunet.com>
 <2BEAF521-7218-415B-98ED-EC0812903479@telecom-bretagne.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <j.hadi123@gmail.com>, Romain KUNTZ <r.kuntz@ipflavors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2BEAF521-7218-415B-98ED-EC0812903479@telecom-bretagne.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 07, 2013 at 12:08:22PM +0100, Emmanuel Thierry wrote:
> 
> This is a nice idea, however you keep the insertion asymmetric. The usage of xfrm marks in non-conflicting cases will be made possible, but it stays disturbing for a user as the initial example will still have the same behavior:
> * Inserting the marked one then the unmarked will succeed
> * Inserting the unmarked then the marked one will fail
> This gives to the user the feeling of an indeterministic behavior of the xfrm module.

This was intended. Inserting the marked one then the unmarked
is a working scenario. Some users might rely on it, so we can't
change this as you proposed.

On the other hand, inserting the unmarked one then the marked
might result in a wrong policy lookup, so we can't allow this.
The only possibility we have, is inserting with different
priorites and that's what I'm proposing.

I fear we have to live with that asymmetric behaviour if
both policies have the same priority.
