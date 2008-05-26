From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 20:08:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805261956090.24924@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi>
 <20080526135940.GB24870@elte.hu> <20080526141252.GA31352@elte.hu>
 <Pine.LNX.4.64.0805261745010.16829@wrl-59.cs.helsinki.fi> <20080526162328.GA9089@elte.hu>
 <Pine.LNX.4.64.0805261926260.24924@wrl-59.cs.helsinki.fi> <20080526165407.GB24098@elte.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1590138542-1211821374=:24924"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48730 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756461AbYEZRIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 13:08:40 -0400
In-Reply-To: <20080526165407.GB24098@elte.hu>
Content-ID: <Pine.LNX.4.64.0805262002580.24924@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1590138542-1211821374=:24924
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805262002581.24924@wrl-59.cs.helsinki.fi>

On Mon, 26 May 2008, Ingo Molnar wrote:

> 
> * Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > > > Hmm, readfds is NULL isn't it?!? Are you sure you straced the 
> > > > right process?
> > > 
> > > yes, i'm stracing the task that is hung unexpectedly.
> > 
> > But that wasn't the receiving process? (I didn't quickly find into 
> > which direction distcc ports go, so I couldn't confirm this). If you 
> > still have that situation at hand, could you check which is the 
> > receiving process (e.g., using netstat -p, the end which has Recv-Q is 
> > the right one) and where it's stuck?
> 
> it wasnt the receiving process. There's no receiving process - which is 
> weird:
> 
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
> tcp        0 207232 europe:37198                europe:distcc               ESTABLISHED 19578/distcc        
> tcp        0      0 europe:ssh                  dione:36284                 ESTABLISHED -                   
> tcp        0      0 europe:ssh                  e2:45910                    ESTABLISHED -                   
> tcp    72283      0 europe:distcc               europe:37198                ESTABLISHED -                   

Just to be sure (please forgive me if you find this nearly an insult :-)), 
did you have enough rights to find out the pid (ie., if that process not 
owned by you then you need superuser privs for that)?

> i just gave it as a general example of why sometimes stracing a task can 
> 'disturb' the observed system and can kick the TCP state machine out of 
> a stall. I did not say it's occuring here.

Yeah, I understood that earlier. Similarly, I just wanted to point out
the end where the problem lies :-).

> > ...It may still be that the receiving process is stuck due to the 
> > non-net related changes you have there.
> 
> the socket does not seem to be owned. It should have closed down? 
> Refcounting issue?

It's well possible that e.g., net namespaces have some bug in handling
of orphaned tcp.

> find below the sysrq-t dump.

...I'll have a look into that as well (though with such I'm on a more 
unfamiliar territory, so it will take a moment).


-- 
 i.
---696208474-1590138542-1211821374=:24924--
