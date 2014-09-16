From: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero window
 is advertised
Date: Tue, 16 Sep 2014 16:49:07 +0400
Message-ID: <541831C3.9020705@oktetlabs.ru>
References: <54170FC0.6020907@oktetlabs.ru> <1410822949.5018.4.camel@localhost> <CAK6E8=fQOA7Mav=a0NJxozAv-AHUV8vcsy+uMJVcH+6zcOE5=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Yuchung Cheng <ycheng@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([84.52.89.53]:45765 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbaIPMtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 08:49:15 -0400
In-Reply-To: <CAK6E8=fQOA7Mav=a0NJxozAv-AHUV8vcsy+uMJVcH+6zcOE5=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/14 03:37, Yuchung Cheng wrote:
> I think the vulnerability comes from the peer/attacker actually
> responds to the probes to evade the orphan counts or memory checks in
> tcp_probe_timer(). This is a gray area of being legit but suspiciously
> mis-behaving?
> maybe have socket option TCP_USER_TIMEOUT for apps to cover conditions
> like these.
Yuchung,
I've tried to use socket option TCP_USER_TIMEOUT, but unfortunately it 
does not help here. I think it is because all packets get their 
acknowledges.

To everybody,
As I understand there is a sensitive difference in the connection 
behavior when the zero window is advertised. In this case there is no 
warranty that after socket closing the connection will be actually 
closed in a finite time. And probably this cannot be regulated at the 
moment. On the other hand if the zero window was not advertised, user 
can be sure that the connection is closed in a finite time despite on 
any peer actions. Moreover user can configure this time with the 
corresponding timeouts. I.e. a user has a lot of options to configure 
different timeouts, but in fact despite on his actions he has no 
guarantee that the connection will be closed at all.

Thanks,
Andrey
