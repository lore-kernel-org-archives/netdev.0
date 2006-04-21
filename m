From: Daniel Drake <dsd@gentoo.org>
Subject: Re: SIOCGIWSCAN wireless event behaviour
Date: Fri, 21 Apr 2006 02:42:06 +0100
Message-ID: <4448386E.6000105@gentoo.org>
References: <4447979F.4050603@gentoo.org> <1145543852.2654.11.camel@localhost.localdomain> <20060420164354.GA32409@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Jouni Malinen <jkmaline@cc.hut.fi>,
	softmac-dev@sipsolutions.net, netdev@vger.kernel.org,
	hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:20588 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932204AbWDUB2P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 21:28:15 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060420164354.GA32409@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	The original behaviour was that the event was sent only when a
> user did request a scan. At that time, cards did not do background
> scanning, so new scan results would be produced only as a result of a
> user scan.
> 	After a short discussion we Dan, we agree that to change that,
> the driver should send a scan whenever a new scan result is available,
> regardless of how it happens (background scan or user scan). This
> allow smart application to synchronise on background scans and avoid
> them generating useless user scans. Minimising the number of user scan
> is actually good.

Thanks for all the responses.

I am not sure if the 'extra' SIOCGIWSCAN event is what is causing 
wpa_supplicant's confusion, but the kind of behaviour I am seeing is 
wpa_supplicant associating to the network, immediately disassociating, 
and then associating again before the connection stabilises. This is 
with wpa_supplicant 0.5.2 connecting to an unencrypted network.

I am also seeing that softmac reassociates with a network after 
wpa_supplicant exits.

Johannes posted a softmac patch earlier which may help (related to 
softmac's handling of SIOCGIWAP). I will do some further investigation 
and provide a more complete report if that doesn't fix it.

Thanks,
Daniel
