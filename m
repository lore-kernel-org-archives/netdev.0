From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Sat, 7 Jun 2003 08:25:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030607082515.6168be46.shemminger@osdl.org>
References: <20030606145835.3a263df8.shemminger@osdl.org>
	<20030607.020528.68152135.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com,
   viro@parcelfarce.linux.theplanet.co.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030607.020528.68152135.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Jun 2003 02:05:28 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Stephen Hemminger <shemminger@osdl.org>
>    Date: Fri, 6 Jun 2003 14:58:35 -0700
>    
>    Phase I:  introduces release_netdev which is the hook to allow later
>       changes to hold onto the net device after the device has potentially
>       unloaded.  Includes patch for the easy to fix devices. 
> 
> Besides naming (thought this was going to be named netdev_drop)
> I have no problems.
> 
> Al?

My (admittedly weak) rational for this was:
	- it seemed more like part of the register/unregister process
	  and those functions are named {un}register_netdevice
	- RTNL should not be held, same as unregister_netdev
	  (vs unregister_netdevice which requires it).
	- release rather than drop because release is used as name
	  in the kobject callback hook

But it's easy to change now.
