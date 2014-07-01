From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [systemd-devel] [PATCH] Use dev_port for the ID of a network
 device.
Date: Tue, 01 Jul 2014 16:18:09 +0300
Message-ID: <53B2B511.8050107@gmail.com>
References: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com> <CAPXgP13o=qZc0q+Af0sd6bLKUawKYw0L_SLqh3VgLZBJ1CfYSA@mail.gmail.com> <20140701123208.GC1204@oc0268524204.ibm.com> <CAG-2HqUM6OSM4-4eVO4KuY38KpKiKTM_H6mdb775VXP+YVuUHg@mail.gmail.com> <CAPXgP126bhV8RLK=457oA+Ci08tEEyjZtnPd9_PxLb3WEVVx8Q@mail.gmail.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36403 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbaGANSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 09:18:15 -0400
Received: by mail-wi0-f170.google.com with SMTP id cc10so7411859wib.3
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 06:18:14 -0700 (PDT)
In-Reply-To: <CAPXgP126bhV8RLK=457oA+Ci08tEEyjZtnPd9_PxLb3WEVVx8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2014 3:59 PM, Kay Sievers wrote:
> On Tue, Jul 1, 2014 at 2:45 PM, Tom Gundersen <teg@jklm.no> wrote:
>> On Tue, Jul 1, 2014 at 2:32 PM, Thadeu Lima de Souza Cascardo
>> <cascardo@linux.vnet.ibm.com> wrote:
>>> On Tue, Jul 01, 2014 at 02:33:19AM +0200, Kay Sievers wrote:
>>>> On Mon, Jun 30, 2014 at 10:36 PM, Thadeu Lima de Souza Cascardo
>>>> <cascardo@linux.vnet.ibm.com> wrote:
>>>>> For network devices on the same PCI function, dev_id should not be used,
>>>>> since its purpose is for IPv6 support on interfaces with the same MAC
>>>>> address.
>>>>>
>>>>> The new dev_port sysfs attribute should be used when it is found. When
>>>>> it is not, using dev_id might work.
>>>>
>>>> I don't see a problem switching this over, but why would we keep using
>>>> dev_id if it is not the right thing to use?
>>>>
>>>> Kay
>>>>
>>>
>>> Because dev_port has only been introduced into Linux 3.15, and some
>>> drivers used dev_id before Linux 3.10. It's not an ideal situation, so I
>>> think it's important to keep some compatibility for the time being. Or
>>> we could simply drop dev_id, and force everyone to do the right thing
>>> and backport dev_port support and fix their drivers.
>>
>> If this fixes a real issue, I guess it would be nice to push the
>> dev_port stuff to -stable. If it is accepted it would solve the
>> backwards compatibility problem, and we could just drop dev_id from
>> udev.
> 
> Let's drop it now and mention it in NEWS. That way, distros which
> really care can add the compat hack to the code.
> 
> Kay
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Acked-by: Amir Vadai <amirv@mellanox.com>

mlx4_en is one of those drivers that wrongly used dev_id and changed to
dev_port.
I guess that having a bug in driver that used dev_id the right way is
worse than bad interface name for drivers that wrongly used it.
Never the less - we should pull dev_port to stable, to minimize the damage.

Amir
