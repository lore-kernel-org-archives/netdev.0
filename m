From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] Wireless extensions rethink
Date: Mon, 7 Jun 2004 11:39:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607113933.4eb42ab3@dell_ss3.pdx.osdl.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF6214@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF6214@orsmsx402.amr.corp.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jun 2004 11:33:10 -0700
"Feldman, Scott" <scott.feldman@intel.com> wrote:

> Jeff suggested in an earlier post that there is an opportunity to
> totally rethink the wireless extensions now that we have wireless-2.6.
> 
> Let's get rid of the iotcl and /proc interfaces as Jeff suggests:
> 
> 1) iw_handler API goes away and is replaced by struct 
>    net_device::wireless_ops (ala ethtool_ops).
> 2) sysfs get/set mapping for wireless_ops.
> 3) iw_statistics just becomes one of the wireless_ops.
> 4) Remove /proc/net/wireless support from wireless.c.  (Already
>    have sysfs support for the same :)
> 5) No private handler support.  If you need private support,
>    pass it in some other way (custom sysfs of modparam).  Or, 
>    better yet, make a case that others could benefit and move
>    into wireless_ops as standard.
> 6) Convert drivers from iw_handler and iw_statistics to
>    wireless_ops.
> 7) Rewrite iw* tools to use sysfs interface rather than ioctl.
>    (scriptable tools?)
> 8) [Optional] Remove iotcl interface.  May want to keep for
>    backward compat with legacy tools?  Easy to map between
>    ioctl and wireless_ops in wireless.c.
> 9) [Open] What to do about wireless events?  Any ideas?
> 
> Proposed sysfs layout:
> 
> 	class/
> 	`-- net
> 	    |-- eth[x]
> 	        |-- wireless
> 	            |-- statistics
> 	            |   |-- beacon
> 			|   |-- crypt
> 	            |   `-- ...
> 	            `-- control
> 	                |-- commit
> 	                |-- name
> 	                |-- network_id
> 	                |-- freq
> 	                `-- ...

That layout would mean that wireless needs to be a separate object
(allocation/structure/kobject).  Not bad, just one more issue to deal with.

Go ahead and view existing sysfs wireless stuff as a prototype since no tools
are using it (that I know of) yet.
