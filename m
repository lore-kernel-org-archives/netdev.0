From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 11:57:47 +0200
Message-ID: <201104271157.49386.carsten@wolffcarsten.de>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com> <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com> <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dominik Kaspar <dokaspar.ietf@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Zimmermann Alexander <zimmermann@nets.rwth-aachen.de>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:57794 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755610Ab1D0J6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 05:58:00 -0400
In-Reply-To: <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On Tuesday 26 April 2011, John Heffner wrote:
> First, TCP is definitely not designed to work under such conditions.
> For example, assumptions behind RTO calculation and fast retransmit
> heuristics are violated.  However, in this particular case my first
> guess is that you are being limited by "cwnd moderation," which was
> the topic of recent discussion here.  Under persistent reordering,
> cwnd moderation can inhibit the ability of cwnd to grow.

it's not just cwnd moderation (of which I'm still in favor, even though I lost 
the argument by inactivity ;-)).

Anyway, there are a lot of things in reordering handling that can be improved. 
Our group (Alexander, Lennart, Arnd, myself and others) has worked on the 
problem for a long time now. This work resulted in an algorithm that is in 
large parts TCP-NCR (RFC4653), but also utilizes information gathered by 
reordering detection for determination of a good DupThresh, fixes a few 
problems in RFC4653 and improves on the reordering detection in Linux when the 
connection has no timestamps option. We implemented "pure" TCP-NCR and our own 
variant in Linux using a modular framework similar to the congestion control 
modules. A lot of measurements and evaluation have gone into the comparison of 
the three algorithms. We are now very close(TM) to a final patch, that is more 
suited for publication on this list and integrates our algorithm into tcp*.
[hc] without introducing the overhead of that modular framework.

Greetings,
Carsten
