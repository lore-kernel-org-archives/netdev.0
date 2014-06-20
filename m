From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Fri, 20 Jun 2014 16:09:49 +0000
Message-ID: <ff458d1b896d4a70a32fa7709911274c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620045704.GA4850@aepfle.de> <20140620051213.GA9960@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Greg KH <greg@kroah.com>, Olaf Hering <olaf@aepfle.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140620051213.GA9960@kroah.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com]
> Sent: Friday, June 20, 2014 1:12 AM
> To: Olaf Hering
> Cc: Haiyang Zhang; netdev@vger.kernel.org; jasowang@redhat.com;
> driverdev-devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> davem@davemloft.net
> Subject: Re: [PATCH net-next] hyperv: Add handler for
> RNDIS_STATUS_NETWORK_CHANGE event
> 
> On Fri, Jun 20, 2014 at 06:57:04AM +0200, Olaf Hering wrote:
> > On Thu, Jun 19, Haiyang Zhang wrote:
> >
> > > The RNDIS_STATUS_NETWORK_CHANGE event is received after the Hyper-V
> host
> > > sleep or hibernation. We refresh network at this time.
> >
> > > +	char *argv[] = { "/etc/init.d/network", "restart", NULL };
> >
> > What happens if that file does not exist? Dead network in the guest?
> > I tend to think if a VM with PV drivers goes to sleep it has to go
> > through the whole suspend/resume cycle, very much like the "LID
> closed"
> > event. So I think this and the other fbdev change that is floating
> > around is wrong.
> 
> Ah, and what about systems with no /etc/init.d/ at all (like
> systemd-based ones)?  You can't have a kernel driver ask userspace to
> restart all networking connections, that seems really wrong.

Olaf and Greg,

Thanks for your reviews. 
On Server Hyper-V, the host sleep/hibernation is not supported. So this 
event won't happen on most deployment of Hyper-V.

On Client Hyper-V (e.g. Windows 8+ on a laptop), the host sleep/hibernation
is supported. If the laptop is moved to another network during sleep, we 
previously need to manually refresh the network (network restart) to renew 
DHCP. With this patch, the network is refreshed on the event.

This command ("/etc/init.d/network restart") exists on our supported distros
currently. We will also look into some better ways to refresh the network for
the distros without this command. I have tried setting IF_OPER_DORMANT then 
IF_OPER_UP, but not working. I will look into the suspend/resume cycle as
well.

Thanks,
- Haiyang
