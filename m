From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/5) replay netdev notifier events on registration
Date: Tue, 13 Jan 2004 16:36:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113163631.1a9c1a59.davem@redhat.com>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040113105843.0d1351cb.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 10:58:43 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Several protocols register for network device notification to detect new new network devices;
> but then have to walk the device list to capture the devices that are already up.
> This leaves a exposed window between when the notifier is registered and when the list walk
> occurs. Also, in several cases, there is a different code path for the pre-existing and
> new devices which leads to bug exposure.
> 
> The solution is to replay the registration and up events for existing devices into the
> new notifier.
> 
> All notifiers in 2.6.1 have been audited and the other patches fix places
> where protocols were doing there own registered device discovery loop.
> 
> Thanks to Al Viro for the suggestion.

Looks good.... are you absolutely sure no remaining notifiers will
barf if they get a register for an already existing device?  I know up
events should be ok...

Anyways, I applied all 5 patches, thanks.
