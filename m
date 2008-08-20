From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] forcedeth: Fix kexec regression
Date: Wed, 20 Aug 2008 15:12:11 +0200
Message-ID: <200808201512.12583.rjw@sisk.pl>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808192045.54779.rjw@sisk.pl> <m1od3ow4oi.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>,
	David Miller <davem@davemloft.net>,
	"Yinghai Lu" <yhlu.kernel@gmail.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	"Jesse Barnes" <jbarnes@virtuousgeek.org>,
	"Simon Arlott" <simon@fire.lp0.eu>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756753AbYHTNJY@vger.kernel.org>
In-Reply-To: <m1od3ow4oi.fsf@frodo.ebiederm.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 20 of August 2008, Eric W. Biederman wrote:
> "Rafael J. Wysocki" <rjw@sisk.pl> writes:
> 
> > From: Rafael J. Wysocki <rjw@sisk.pl>
> >
> > forcedeth: Fix kexec regression
> >
> > Fix regression tracked as
> > http://bugzilla.kernel.org/show_bug.cgi?id=11361 and
> > caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
> > ("[netdrvr] forcedeth: setup wake-on-lan before shutting down")
> > that makes network adapters integrated into the NVidia
> > MCP55 chipsets fail to work in kexeced kernels.  The problem appears
> > to be that if the adapter is put into D3_hot during ->shutdown(),
> > it cannot be brought back into D0 after kexec (ref.
> > http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore,
> > only put forcedeth into D3 during ->shutdown() if the system is to be
> > powered off.
> 
> Any chance we can fix this by teaching the forcedeth driver to
> bring a card out of PCI_D3hot?

Maybe, but that's not what I'm able to do at the moment. :-)

Yinghai Lu thinks that the hardware has a problem with that, though.

> The kexec on panic guys are going to need that and it is just generally
> more robust all of the way around than a special case in shutdown
> based on system_state.

Actually, system_state == SYSTEM_POWER_OFF is a special case already, since
it is the only case in which ACPI gets involved.

Thanks,
Rafael
