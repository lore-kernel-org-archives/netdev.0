From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Mon, 13 Oct 2003 12:51:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013125156.63c3be24.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F8455BE.8080300@sgi.com>
	<20031008183742.GA24822@wotan.suse.de>
	<20031008122223.1ba5ac79.davem@redhat.com>
	<20031008202248.GA15611@oldwotan.suse.de>
	<3F8702FF.70500@sgi.com>
	<20031010192036.GA31727@wotan.suse.de>
	<3F8802E6.5030601@sgi.com>
	<20031011131921.GC21763@wotan.suse.de>
	<20031011105054.0e16a607.davem@redhat.com>
	<3F8B02D2.4020007@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, modica@sgi.com, netdev@oss.sgi.com, jgarzik@pobox.com,
        jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnip@sgi.com
In-Reply-To: <3F8B02D2.4020007@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Oct 2003 14:53:54 -0500
John Partridge <johnip@sgi.com> wrote:

> Could we create a module argument like "do_5701_align" and just give it a -1
> default which does NOT do the copy but if we give the arg 1, 0, whatever it
> DOES to the copy to align the buffs ?

Absolutely not, we're not going to put super-hacky module parameters
into the driver just because you guys don't want to create and use the
CONFIG_UNALIGNED_EXPENSIVE config option needed to fix this properly.

> That way all the default comiles work and no CONFIG option for people
> who compile all defaults and don't want to re compile the kernel for
> this issue.
> 
> Is that acceptable ?

No it's not.

When you add this new config option, and set it on ia64, the only
thing that will need to be rebuilt is the tg3 driver, no other thing
in the entire kernel tree should trigger a dependency on this new
config option.

I don't understand why at all you guys are trying to avoid fixing this
the proper way, you will meet only resistence from me if you continue
doing that :)
