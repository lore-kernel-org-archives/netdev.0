From: Debashis Dutt <debdut@gmail.com>
Subject: Re: [PATCH 2/2] bna: Add Generic Netlink Interface
Date: Wed, 18 May 2011 15:28:04 -0700
Message-ID: <BANLkTin+kRsGFWG9N16E9Red5SM=g+haSw@mail.gmail.com>
References: <1305694621-28023-1-git-send-email-rmody@brocade.com>
	<1305694621-28023-3-git-send-email-rmody@brocade.com>
	<20110518120005.GC3762520@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rasesh Mody <rmody@brocade.com>, davem@davemloft.net,
	netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	Debashis Dutt <ddutt@brocade.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54467 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010Ab1ERW2G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:28:06 -0400
Received: by ewy4 with SMTP id 4so587315ewy.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 15:28:05 -0700 (PDT)
In-Reply-To: <20110518120005.GC3762520@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2011 at 5:00 AM, David Lamparter <equinox@diac24.net> w=
rote:
> On Tue, May 17, 2011 at 09:57:01PM -0700, Rasesh Mody wrote:
>> This patch adds the generic netlink communication interface to BNA d=
river. The
>> in-kernel generic netlink infrastructure can be used to collect hard=
ware
>> specific control information and control attributes. The driver make=
s use of
>> the "doit" handler provided by the generic netlink layer to accompli=
sh this.
> [...]
>> +struct bnad_genl_ioc_info {
>> + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 status;
>> + =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 bnad_num;
>> + =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 rsvd;
>> + =A0 =A0 char =A0 =A0 =A0 =A0 =A0 =A0serialnum[64];
>> + =A0 =A0 char =A0 =A0 =A0 =A0 =A0 =A0hwpath[BFA_STRING_32];
>> + =A0 =A0 char =A0 =A0 =A0 =A0 =A0 =A0adapter_hwpath[BFA_STRING_32];
>> + =A0 =A0 char =A0 =A0 =A0 =A0 =A0 =A0guid[BFA_ADAPTER_SYM_NAME_LEN*=
2];
>> + =A0 =A0 char =A0 =A0 =A0 =A0 =A0 =A0name[BFA_ADAPTER_SYM_NAME_LEN]=
;
>> + =A0 =A0 char =A0 =A0 =A0 =A0 =A0 =A0port_name[BFA_ADAPTER_SYM_NAME=
_LEN];
>> + =A0 =A0 char =A0 =A0 =A0 =A0 =A0 =A0eth_name[BFA_ADAPTER_SYM_NAME_=
LEN];
>> + =A0 =A0 u64 =A0 =A0 =A0 =A0 =A0 =A0 rsvd1[4];
>> + =A0 =A0 mac_t =A0 =A0 =A0 =A0 =A0 mac;
>> + =A0 =A0 mac_t =A0 =A0 =A0 =A0 =A0 factory_mac; =A0 =A0/* Factory m=
ac address */
>> + =A0 =A0 mac_t =A0 =A0 =A0 =A0 =A0 current_mac; =A0 =A0/* Currently=
 assigned mac address */
>> + =A0 =A0 enum bfa_ioc_type =A0 =A0 ioc_type;
>> + =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 pvid; =A0 =A0 =A0 =A0 =A0 /* P=
ort vlan id */
>> + =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 rsvd2;
>> + =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 host;
>> + =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 bandwidth; =A0 =A0 =A0/* For P=
=46 support */
>> + =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 rsvd3;
>> +};
>> +
>> +struct bnad_genl_ioc_attr {
>> + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 status;
>> + =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 bnad_num;
>> + =A0 =A0 u16 =A0 =A0 =A0 =A0 =A0 =A0 rsvd;
>> + =A0 =A0 struct bfa_ioc_attr =A0ioc_attr;
>> +};
>
> These things all look like they're better put into sysfs. Why would y=
ou
> create a genl protocol just to query some presumably static attribute=
s?
>
>
> -David
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

Hi David,

There could be different ways of doing it, but the reason we chose to g=
o
the generic netlink route are as follows:

1) The recommended format of sysfs (as per sysfs.txt in kernel document=
ation)
   is one single line of ASCII text per file.

   As a result this:
   a) if there are a lot of attributes to be collected,
         the driver will end up in creating that many sysfs files.
   b) Reading / writing each attribute will result in a set of
        [open()/read()/write()/close()] calls.

   This is not very scalable, particularly if we want to expand on this
   interface for better management functionality in the future.

   Instead, generic netlink provides a much better way of multiplexing =
data
   over a single socket.

2) Asynchronous event notifications can be much easily handled using th=
e generic
     netlink interface.

Thanks
--Debashis
