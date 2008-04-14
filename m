From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 13:55:08 +0200
Message-ID: <3ae72650804140455l4bb2afc2i4c54e58f3be1f931@mail.gmail.com>
References: <ftdb3v$tls$1@ger.gmane.org> <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
	 <1208171478.31695.58.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Marco d'Itri" <md@linux.it>, "Harald Hoyer" <harald@redhat.com>,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1208171478.31695.58.camel@pmac.infradead.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2008 at 1:11 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Mon, 2008-04-14 at 11:08 +0100, David Woodhouse wrote:
>  > One alternative approach would be to use dev->dev_id (is that exported
>  > in sysfs?). That's what IPv6 addrconf uses in addition to the MAC
>  > address to provide a unique address when MAC addresses are shared.
>  >
>  > We could modify the libertas and gelic (and any other affected) drivers
>  > to provide a dev_id, make sure it's exported in sysfs, and then use that
>  > in the udev rules. Would that make you happy?
>
>  That would look something like this (in fact, I think it would let us
>  get rid of the special case for S390 too)...
>
>  --- ./udev-120/extras/rule_generator/75-persistent-net-generator.rules~ 2008-04-03 20:12:53.000000000 +0100
>  +++ ./udev-120/extras/rule_generator/75-persistent-net-generator.rules  2008-04-14 11:52:46.000000000 +0100
>  @@ -18,7 +18,7 @@ SUBSYSTEM!="net", GOTO="persistent_net_g
>   NAME=="?*", GOTO="persistent_net_generator_end"
>
>   # device name whitelist
>  -KERNEL!="eth*|ath*|wlan*[0-9]|ra*|sta*|ctc*|lcs*|hsi*", GOTO="persistent_net_generator_end"
>  +KERNEL!="eth*|ath*|wlan*[0-9]|ra*|sta*|ctc*|lcs*|hsi*|msh*", GOTO="persistent_net_generator_end"
>
>   # ignore Xen virtual interfaces
>   SUBSYSTEMS=="xen", GOTO="persistent_net_generator_end"
>  @@ -29,6 +29,9 @@ ENV{MATCHADDR}="$attr{address}"
>   # match interface type
>   ENV{MATCHIFTYPE}="$attr{type}"
>
>  +# match dev_id
>  +ENV{MATCHDEVID}="$attr{dev_id}"
>  +

Sure, looks good. Let me know when the kernel part gets merged, and I
will apply that.

Thanks,
Kay
