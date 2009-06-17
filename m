From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: lots of cpu time spent in skb_copy_bits() in net-next with small
 mtu
Date: Wed, 17 Jun 2009 09:57:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906170936320.28187@melkinkari.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0906122248450.31625@melkinkari.cs.Helsinki.FI>
 <1245180000.7150.6.camel@Maple> <Pine.LNX.4.64.0906170831020.28187@melkinkari.cs.Helsinki.FI>
 <20090616.225316.263195307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243445-1534574638-1245221839=:28187"
Cc: john.dykstra1@gmail.com, ben.lahaise@neterion.com,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49642 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbZFQG5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 02:57:17 -0400
In-Reply-To: <20090616.225316.263195307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-1534574638-1245221839=:28187
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT

On Tue, 16 Jun 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 17 Jun 2009 08:46:56 +0300 (EEST)
> 
> > While I took a very short view on it earlier I notice that handling of the 
> > case when head is at the last skb and tail is at the end of queue was 
> > changed (without mention in the commit message whether it was 
> > intentionally) in the Dave's change (we used to exit at skb == tail while 
> > we don't necessarily do that anymore but take the additional checks that 
> > are made inside the loop ub tcp_collapse()). It would be nice if Dave 
> > would split that kind of complex transformation into more easily 
> > verifiable changes, even if the intermediate form itself would not remain 
> > in the final form, as is it's rather hard to track it all :-).
> > 
> > I'm not sure if that change is significant though as one might view it as 
> > the opposite, ie., that the previous was unintented early exit since we 
> > wouldn't collapse bloated skb in the end but who knows... ...But I'm yet 
> > to really _understand_ everything that is going on there.
> 
> Sorry, will be more careful in the future. :-)

I re-looked into the problem I supposedly found earlier and it seems that
it turned out to be a false alarm... Huoh, how complex it is track that 
change :-).

> Can we atleast verify that applying the following revert patch makes
> the problem go away?  (it's a combination revert of commits
> 2df9001edc382c331f338f45d259feeaa740c418 and
> 915219441d566f1da0caa0e262be49b666159e17).

Yeah, that's a good start...

-- 
 i.

ps. I'll be out of reach of email access for a week.

---696243445-1534574638-1245221839=:28187--
