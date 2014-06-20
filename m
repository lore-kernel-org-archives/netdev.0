From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Thu, 19 Jun 2014 22:12:13 -0700
Message-ID: <20140620051213.GA9960@kroah.com>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620045704.GA4850@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
 Haiyang Zhang <haiyangz@microsoft.com>, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, davem@davemloft.net
To: Olaf Hering <olaf@aepfle.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140620045704.GA4850@aepfle.de>
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

On Fri, Jun 20, 2014 at 06:57:04AM +0200, Olaf Hering wrote:
> On Thu, Jun 19, Haiyang Zhang wrote:
> 
> > The RNDIS_STATUS_NETWORK_CHANGE event is received after the Hyper-V host
> > sleep or hibernation. We refresh network at this time.
> 
> > +	char *argv[] = { "/etc/init.d/network", "restart", NULL };
> 
> What happens if that file does not exist? Dead network in the guest?
> I tend to think if a VM with PV drivers goes to sleep it has to go
> through the whole suspend/resume cycle, very much like the "LID closed"
> event. So I think this and the other fbdev change that is floating
> around is wrong.

Ah, and what about systems with no /etc/init.d/ at all (like
systemd-based ones)?  You can't have a kernel driver ask userspace to
restart all networking connections, that seems really wrong.

greg k-h
