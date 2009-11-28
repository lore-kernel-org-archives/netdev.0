From: Patrick McHardy <kaber@trash.net>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 18:07:26 +0100
Message-ID: <4B1158CE.90803@trash.net>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>	 <1259137434.9191.3.camel@nienna.balabit>	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>	 <20091128151515.GA20476@sch.bme.hu>  <4B1145F1.3090704@trash.net> <1259424278.3864.16.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40379 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbZK1RHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 12:07:23 -0500
In-Reply-To: <1259424278.3864.16.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Sat, 2009-11-28 at 16:46 +0100, Patrick McHardy wrote:
> 
>> The root cause seems to be an invalid assumption, marks are often not
>> used in a symetric fashion as required by RPF.
> 
> The only assumption is: if you set set up a mark on incoming, you are
> asking the reverse validation that is to be used to consider that mark.
> 
> This has nothing to do with RPF really;-> RPF is off. There is a legit
> bug in the old setup that has a table programmed with a route that is
> not unicast. 

Right, its source validation. But the setup is valid, its asking for
specifically marked packets to be delivered locally for transparent
proxying. There's no requirement that rules using marks must resolve
to RTN_UNICAST.

>> Since this patch has already proven to break existing setups, I think
>> it should be reverted or the behaviour made optional with a default to
>> off.
> 
> I disagree. What other setup is broken? ;->

Isn't one setup usually considered enough? :)
