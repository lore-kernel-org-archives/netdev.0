From: Mason <slash.tmp@free.fr>
Subject: Re: Toggling link state breaks network connectivity
Date: Tue, 13 Jun 2017 17:32:14 +0200
Message-ID: <4b6d6e75-2054-d996-c0ec-fedc6fe3b57b@free.fr>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
 <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:37824 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753095AbdFMPcb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 11:32:31 -0400
In-Reply-To: <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/06/2017 17:07, Mason wrote:

> I did note something that seems important.
> 
> If I toggle the link state in software, then connectivity breaks.
> 
> If I unplug the ethernet cable, and replug, connectivity remains.
> 
> The difference is that plugging/unplugging doesn't call the
> .ndo_stop callback. But 'ip link set eth0 down' does call it.
> 
> Should the .ndo_stop callback be symmetric to the .ndo_open callback?
> In other words, should .ndo_open(); .ndo_stop(); be a NOP?

I changed the ndo_open callback to a wrapper that calls:

	nb8800_open(dev);
	nb8800_stop(dev);
	nb8800_open(dev);

With this change, connectivity is broken from the start.
Valid ARP requests are correctly *sent* but the corresponding
ARP replies are not received.

I'm hoping this limits the scope of what needs to be investigated.

Regards.
