From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH net-next 09/17] net: Allow userns root control of the
	core of the network stack.
Date: Sat, 17 Nov 2012 00:28:36 +0000
Message-ID: <1353112116.2743.79.camel@bwh-desktop.uk.solarflarecom.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
	<1353070992-5552-9-git-send-email-ebiederm@xmission.com>
	<50A645C2.1000604@parallels.com> <871uft8vpm.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871uft8vpm.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-16 at 06:32 -0800, Eric W. Biederman wrote:
> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> 
> > On 11/16/2012 05:03 PM, Eric W. Biederman wrote:
> >> +	if (!capable(CAP_NET_ADMIN))
> >> +		return -EPERM;
> >> +
> >>  	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
> >
> > You mean ns_capable here?
> 
> No.  There I meant capable.
> 
> I deliberately call capable here because I don't understand what
> the tx_queue_len well enough to be certain it is safe to relax
> that check to be just ns_capable.
> 
> My get feel is that allowing an unprivileged user to be able to
> arbitrarily change the tx_queue_len on a networking device would be a
> nice way to allow queuing as many network packets as you would like with
> kernel memory and DOSing the machine.
> 
> So since with a quick read of the code I could not convince myself it
> was safe to allow unprivilged users to change tx_queue_len I left it
> protected by capable.  While at the same time I relaxed the check in
> netdev_store to be ns_capable.

Tor the same reason you had better be very selective about which ethtool
commands are allowed based on per-user_ns CAP_NET_ADMIN.  Consider for a
start:

ETHTOOL_SMSGLVL => fill up the system log
ETHTOOL_SEEPROM => brick the NIC
ETHTOOL_FLASHDEV => brick the NIC; own the system if it's not using an IOMMU

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
