From: Jeremy Ashton <jeremy.ashton@shopify.com>
Subject: Re: [Intel-wired-lan] i40e error handling LLDP messages from Arista switches
Date: Tue, 19 Apr 2016 16:20:28 -0400
Message-ID: <CAH9ADKWKYYqahQdrso3Nf556WzuF4ZnVPkz9pGO0NqDsQNbqOQ@mail.gmail.com>
References: <CAH9ADKU7DMbEoWD8Qu+=hXr2Pfhga5D_=FCz7btea2oV9=GdzA@mail.gmail.com>
 <739353123C992A4C8800D77E20942590905248DF@ORSMSX103.amr.corp.intel.com>
 <739353123C992A4C8800D77E2094259090524953@ORSMSX103.amr.corp.intel.com>
 <CAH9ADKW4cse2v88xwOisr__R5w-O7siTMhAa2eUAUWK1hUtt9Q@mail.gmail.com> <739353123C992A4C8800D77E2094259090524A59@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Parikh, Neerav" <neerav.parikh@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35495 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbcDSUUs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 16:20:48 -0400
Received: by mail-ob0-f173.google.com with SMTP id n10so18767597obb.2
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 13:20:48 -0700 (PDT)
In-Reply-To: <739353123C992A4C8800D77E2094259090524A59@ORSMSX103.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a way to disable the lldp daemon running in the firmware?

On Tue, Apr 19, 2016 at 2:31 PM, Parikh, Neerav <neerav.parikh@intel.co=
m> wrote:
>
>
>> -----Original Message-----
>> From: Jeremy Ashton [mailto:jeremy.ashton@shopify.com]
>> Sent: Tuesday, April 19, 2016 11:10 AM
>> To: Parikh, Neerav <neerav.parikh@intel.com>
>> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
>> Subject: Re: [Intel-wired-lan] i40e error handling LLDP messages fro=
m Arista
>> switches
>>
>> So, what commands exactly are you looking to have run?  Would packet
>> capture of the lldp traffic help?
>>
> LLDP is running in the i40e device firmware so unless you've a packet=
 capture on
> the wire (Xgig) you may not see that in the wireshark/tshark on the h=
ost system.
>
> The debugfs commands I was referring to below can help capture some
> information; and for that you may need to mount the debugfs file syst=
em on
> your setup. If debugfs is supported then once you've that mounted and=
 have the
> i40e driver loaded then you may see an entry named "i40e" under the m=
ount point.
> Assuming debugfs is mounted on /sys/kernel/debug the i40e directory w=
ill be under
> /sys/kernel/debug/i40e. This directory will have entry for each PCIe =
device being
> managed by the i40e driver. You can select the PCIe device that maps =
to the device
> in question and can run the commands like:
> echo "dump port" > /sys/kernel/debug/i40e/<pci-path>/command
> echo "lldp get local" > /sys/kernel/debug/i40e/<pci-path>/command
> echo "lldp get remote" > /sys/kernel/debug/i40e/<pci-path>/command
>
> The output of these commands will show up in the dmesg log.
>
> One another I noticed in your thread on the PF_RING bz is that you're=
 using inbox
> Ubuntu driver. Have you tried with current upstream and seen this iss=
ue?
>
> Thanks,
> Neerav
>
>> On Tue, Apr 19, 2016 at 1:53 PM, Parikh, Neerav <neerav.parikh@intel=
=2Ecom>
>> wrote:
>> > Resending as the original email was sent in HTLM format and hence =
my reply
>> went in that format
>> > as well; which got rejected by netdev mailer.
>> >
>> >> -----Original Message-----
>> >> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuos=
l.org] On
>> Behalf Of Parikh, Neerav
>> >> Sent: Tuesday, April 19, 2016 10:45 AM
>> >> To: Jeremy Ashton <jeremy.ashton@shopify.com>
>> >> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
>> >> Subject: Re: [Intel-wired-lan] i40e error handling LLDP messages =
from Arista
>> switches
>> >>
>> >> > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osu=
osl.org] On
>> Behalf Of Jeremy Ashton
>> >> > Sent: Tuesday, April 19, 2016 10:26 AM
>> >> > Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
>> >> > Subject: [Intel-wired-lan] i40e error handling LLDP messages fr=
om Arista
>> switches
>> >> >
>> >> > I have been trying to get pf_ring with zc running on ubuntu 14.=
04.  The
>> thread can be found here:
>> >> >
>> >> > https://github.com/ntop/PF_RING/issues/81
>> >> >
>> >> > Unfortunately it seems there is a bug in i40e which is carried =
into the code
>> base for i40e_zc.
>> >> >
>> >> > $ modinfo i40e
>> >> > filename:       /lib/modules/3.19.0-58-
>> generic/kernel/drivers/net/ethernet/intel/i40e/i40e.ko
>> >> > version:        1.2.2-k
>> >> > license:        GPL
>> >> > description:    Intel(R) Ethernet Connection XL710 Network Driv=
er
>> >> > author:         Intel Corporation, <e1000-devel@lists.sourcefor=
ge.net>
>> >> > srcversion:     E3DEEE00F49BBFBB8FF33A7
>> >> > alias:          pci:v00008086d00001586sv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d00001585sv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d00001584sv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d00001583sv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d00001581sv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d00001580sv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d0000157Fsv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d00001574sv*sd*bc*sc*i*
>> >> > alias:          pci:v00008086d00001572sv*sd*bc*sc*i*
>> >> > depends:        ptp,vxlan
>> >> > intree:         Y
>> >> > vermagic:       3.19.0-58-generic SMP mod_unload modversions
>> >> > signer:         Magrathea: Glacier signing key
>> >> > sig_key:
>> DE:B3:43:0A:26:E6:7D:3D:3B:54:B9:DD:13:25:B3:3A:46:B2:F2:DD
>> >> > sig_hashalgo:   sha512
>> >> > part:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)
>> >> >
>> >> >
>> >> > I wonder if someone might offer some insight as to the next ste=
ps to
>> debug/resolve this.
>> >> >
>> >> > Cheers.
>> >> >
>> >> > Can you send us the dmesg output after running i40e debugfs com=
mands
>> >> > viz. =E2=80=9Cdump port=E2=80=9D, =E2=80=9Cllpd get local=E2=80=
=9D , =E2=80=9Clldp get remote=E2=80=9D, for the port that is
>> showing
>> >> > this behavior? Also, do you happen to know what is the Arista s=
ide
>> configuration?
>> >> > This will help us debug better.
>> >> >
>> >> > Thanks,
>> >> > Neerav
