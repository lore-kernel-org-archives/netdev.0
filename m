From: Ronald Pina <pinaronald@gmail.com>
Subject: Re: Adjusting patch to support napi weighting on kernel 3.4.1
Date: Thu, 12 Mar 2015 11:34:03 +0100
Message-ID: <CAONBAae9+ufMdAcWJ2OFopMpUzvkgV16R7r2TLiL0_T1nc--kA@mail.gmail.com>
References: <CAONBAadh1ZcH+D8XOkaLBWS0ssV4SVCNCq616Q8EK4kjY_G=xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35131 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbbCLKeE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 06:34:04 -0400
Received: by ieclw3 with SMTP id lw3so31557393iec.2
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 03:34:04 -0700 (PDT)
In-Reply-To: <CAONBAadh1ZcH+D8XOkaLBWS0ssV4SVCNCq616Q8EK4kjY_G=xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I am trying to adjust the of Stephen Hemminger patch (
http://marc.info/?l=3Dlinux-netdev&m=3D111773621018096&w=3D2 ),  suport=
ing
napi weight changes for every network interfaces and  including
virtual paravirtualized network interfaces like xen vif (since they
use napi now) on kernel 3.4.1.

The changes are listed below.

+static int change_weight(struct napi_struct *napi, unsigned long new_w=
eight)
+{
+         napi->weight =3D new_weight;
+         return 0;
+ }

+ static ssize_t weight_store(struct device *dev, struct
device_attribute *attr, const char *buf, size_t len)
+ {
+         return netdev_store(dev, attr, buf, len, change_weight);
+ }
+NETDEVICE_SHOW_RW ( weight, fmt_dec);


static struct attribute *net_class_attrs[] =3D {
&dev_attr_netdev_group.attr,
         &dev_attr_type.attr,
         &dev_attr_dev_id.attr,
         &dev_attr_dev_port.attr,
         &dev_attr_iflink.attr,
         &dev_attr_ifindex.attr,
         &dev_attr_name_assign_type.attr,
         &dev_attr_addr_assign_type.attr,
+      &dev_attr_addr_weight.attr,
         &dev_attr_link_mode.attr,
         &dev_attr_address.attr,
         &dev_attr_broadcast.attr,
         &dev_attr_speed.attr,
         &dev_attr_duplex.attr,
         &dev_attr_dormant.attr,
         &dev_attr_operstate.attr,
         &dev_attr_carrier_changes.attr,
         &dev_attr_ifalias.attr,
         &dev_attr_carrier.attr,
         &dev_attr_mtu.attr,
         &dev_attr_flags.attr,
         &dev_attr_tx_queue_len.attr,
         &dev_attr_gro_flush_timeout.attr,
         &dev_attr_phys_port_id.attr,
         &dev_attr_phys_switch_id.attr,
         NULL,
 };

But the weight prameter is on the napi_structure, not on the struct
net_device.   I tried to compile it but it shows:
-----------------------------------------------------------------------=
---
net/core/net-sysfs.c: In function =E2=80=98format_weight=E2=80=99:
net/core/net-sysfs.c:268: error: =E2=80=98const struct net_device=E2=80=
=99 has no
member named =E2=80=98weight=E2=80=99
net/core/net-sysfs.c: In function =E2=80=98store_weight=E2=80=99:
net/core/net-sysfs.c:280: warning: passing argument 5 of
=E2=80=98netdev_store=E2=80=99 from incompatible pointer type
net/core/net-sysfs.c:80: note: expected =E2=80=98int (*)(struct net_dev=
ice *,
long unsigned int)=E2=80=99 but argument is of type =E2=80=98int (*)(st=
ruct
napi_struct *, long unsigned int)=E2=80=99
make[2]: *** [net/core/net-sysfs.o] Error 1
make[1]: *** [net/core] Error 2
make: *** [net] Error 2

-----------------------------------------------------------------------=
-----

How can i reference struct  napi_stuct inide the function
change_weight, and how can i pass the new weight to netdev_store
function ?

Thanks in advance
