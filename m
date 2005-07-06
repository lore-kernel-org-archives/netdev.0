From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Wed, 6 Jul 2005 11:53:13 -0700
Message-ID: <Pine.CYG.4.58.0507061138030.1208@mawilli1-desk2.amr.corp.intel.com>
References: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
 <20050702081346.GA20789@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Radheka Godse <radheka.godse@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20050702081346.GA20789@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 2 Jul 2005, Greg KH wrote:

>
> This violates the 1-value-per-sysfs file rule.  Please fix this up.
>

Thanks for looking at our patch, Greg.  We're aware of the "one value"
rule, but we really couldn't find any way to do what we wanted to do
any other way.  The kernel docs do indicate that it is "socially
acceptable to express an array of values of values of the same type",
which this certainly is.

In this particular case, the file /sys/class/net/bonding_masters contains
the names of all of the bonds in the system.  By default, the module
creates a single bond when it loads, thus:

$ cat bonding_masters
bond0

You can add and remove bonds just by writing to the file.  In keeping with
the "array of types" concept, you must write the names of all active bonds
back to the file.  Thus,

$ echo "bond0 bond1" > bonding_masters

retains bond0 and adds bond1.  Likewise,

$ echo "bond1 bond2" > bonding_masters

retains bond1, deletes bond0, and adds bond2.

The slaves file in each bond's directory acts the same way, and is used to
add or remove slaves from each individual bond.

We discussed this design extensively before implementation, but really
couldn't come up with anything as elegant or easy to understand as this
scheme.  Since it really is an array of similar values, we are hoping that
it will be viewed as socially acceptable.

-Mitch
