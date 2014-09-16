From: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero window
 is advertised
Date: Tue, 16 Sep 2014 18:08:15 +0400
Message-ID: <5418444F.7010403@oktetlabs.ru>
References: <54170FC0.6020907@oktetlabs.ru>	 <1410822949.5018.4.camel@localhost> <54183150.5030400@oktetlabs.ru> <1410872966.7106.187.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([84.52.89.53]:48076 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169AbaIPOI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 10:08:27 -0400
In-Reply-To: <1410872966.7106.187.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/14 17:09, Eric Dumazet wrote:
> 1) TCP_USER_TIMEOUT would be the fit for this, but its current
> implementation do not take care of the probes sent, even in FIN_WAIT
> state when in this zero window mode. A patch would be needed.
>
> 2) SO_LINGER, timeout=0 might work.
I tried to set SO_LINGER with non-zero timeout before reporting the bug, 
it did not help. But I've just tried again with the zero timeout 
(l_linger=0) and it works, the connection has been interrupted 
immediately after socket closing, RST packet has been sent. It seems 
like a bug, SO_LINGER with non-zero timeout does not interrupt the 
connection.

Thanks,
Andrey
