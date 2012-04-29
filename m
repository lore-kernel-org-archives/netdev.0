From: admin <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Sun, 29 Apr 2012 19:34:48 +0200
Message-ID: <4F9D7BB8.4000007@coldplug.net>
References: <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com> <CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com> <20120427094637.GV3157@wantstofly.org> <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com> <20120427095842.GW3157@wantstofly.org> <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com> <20120427101732.GX3157@wantstofly.org> <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com> <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com> <20120427185809.GZ3157@wantstofly.org> <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com> <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com> <CAJfuBxw7YFAC9CLAGNmg3nM_g2xH2vuiz07D-3xOcyn2XuP5vA@mail.gmail.com> <CA+icZUVT6
 kvqj47x26FU2qjbMHc=jr9_Lso=zduf_cmcSrv=UQ@mail.gmail.com> <CAJfuBxwz2PmNY37VB7Wx+GdQcOcS6Y96EM_JNtvs-dyv-imL6g@mail.gmail.com> <CA+icZUXrGuY+0GLJCmL9CH7i7vnvXAyAE2vXNAXM_3Q30B4nPA@mail.gmail
 .com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090609030401090305070906"
Cc: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+icZUXrGuY+0GLJCmL9CH7i7vnvXAyAE2vXNAXM_3Q30B4nPA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090609030401090305070906
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 04/29/2012 01:26 AM, Sedat Dilek wrote:
> On Sun, Apr 29, 2012 at 1:11 AM, Jim Cromie<jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>  wrote:
>> On Sat, Apr 28, 2012 at 4:49 PM, Sedat Dilek<sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>  wrote:
>>> On Sun, Apr 29, 2012 at 12:36 AM, Jim Cromie<jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>  wrote:
>>>>>> As already pointed out, no Marwell WLAN hardware here. Marvell comics
>>>>>> of course :-).
>> (I had to leave that one..:-)
>>
>>
>>
>>>>> A new tarball from lautriv with same outputs as before, but now tested
>>>>> with Linux-3.4-rc4.
>>>>>
>>>>> - Sedat -
>>>>
>>>> heres my logs, using firmware extracted by Sedat's script,
>>>> and the patch on mwl8k.c
>>>>
>>>> bottom-line, it appears to be working.
>>>>
>>>> its contents are a bit more pedantic, and includes data for
>>>> another wifi card (rtl8180 based) also in the box.
>>>> It was obtained by this script:
>>>>
>>>> #!/bin/bash
>>>>
>>>> # dmesg (Linux-3.3.3)
>>>> # e_n_a (/etc/network/interfaces)
>>>> # ifconfig output
>>>> # iwconfig output
>>>> # iw_phy output
>>>> # ps_axu (WPA) output
>>>>
>>>> devs="wlan0 wlan1"
>>>> apmac=00:14:d1:e8:65:0a
>>>>
>>>> loudly () {
>>>>     echo "# $@"
>>>>     fname=`echo $@ | sed -e 's/ /-/g'`
>>>>     $@ 2>  $fname-err | tee $fname
>>>>     [ $? != 0 ]&&  echo non-zero exit on $fname: $?
>>>>     [ -s $fname-err ] || rm $fname-err
>>>> }
>>>>
>>>> ( iw --debug event -f>  iw-event-f )&
>>>> pid_event=$!
>>>>
>>>> for N in 0 1 ; do
>>>>     loudly iw dev wlan$N interface add fish$N type monitor # flags none
>>>>     loudly iw dev fish$N set channel 8
>>>>     loudly ifconfig fish$N up
>>>>     ( tcpdump -i fish$N -s 65000 -p -U -w  fish$N.dump )&
>>>>     pid_dump_fish$N=$!
>>>> done
>>>>
>>>> loudly iw list
>>>>
>>>> #loudly iwspy
>>>> # gives: Interface doesn't support wireless statistic collection
>>>>
>>>> for dev in $devs ; do
>>>>     loudly ifconfig $dev
>>>>     loudly iwconfig $dev
>>>>     loudly iwlist $dev scan
>>>>     loudly iw dev $dev info
>>>>     loudly iw dev $dev link
>>>>     loudly iw dev $dev scan
>>>>     loudly iw dev $dev survey dump
>>>> done
>>>>
>>>> for phy in $phys ; do
>>>>     loudly iw phy $phy info
>>>> done
>>>>
>>>> # these are unsupported on wlan0
>>>> loudly iw dev wlan1 survey dump
>>>> loudly iw dev wlan1 station dump
>>>> loudly iw dev wlan1 station get $apmac
>>>>
>>>>
>>>> for N in 0 1 ; do
>>>>     loudly iw dev fish$N del
>>>> done
>>>>
>>>> kill $pid_dump_fish0 $pid_dump_fish0
>>>> kill $pid_event
>>>>
>>>> dmesg>  dmesg
>>>>
>>>> grep -vE '^#|key' /etc/network/interfaces>  e_n_a
>>>>
>>>> exit
>>> Hi Jim,
>>>
>>> thanks for your testing and the nice testcase-script!
>>>
>>> lautriv you wanna run some more tests with Jim's script?
>>>
>>> Jim, how stable/fast/reliable is your WLAN connection?
>>> Suspend/resume tested?
>> I havent tested reliability in any way.
>> in fact, I havent tested any data-xfer per se,
>> will do an iperf test soon.
>>
>> That said, bitrate is quite low, I havent looked at why.
>>
>> jimc@chumly:~/projects/lx/wifi/mwl8k-8361p-logs$ grep -i MBit *
>> iw-dev-wlan0-link:      tx bitrate: 11.0 MBit/s
>> iw-dev-wlan1-link:      tx bitrate: 1.0 MBit/s
>> iw-dev-wlan1-station-dump:      tx bitrate:     1.0 MBit/s
>> iw-dev-wlan1-station-get-00:14:d1:e8:65:0a:     tx bitrate:     1.0 MBit/s
>>
>> my laptop is much faster than both cards in the soekris box, to same AP
>>
>> Connected to 00:14:d1:e8:65:0a (on wlan0)
>>         SSID: yoduh
>>         freq: 2447
>>         RX: 191134302 bytes (2120068 packets)
>>         TX: 17440426 bytes (120666 packets)
>>         signal: -45 dBm
>>         tx bitrate: 54.0 MBit/s
>>
>>         bss flags:
>>         dtim period:    0
>>         beacon int:     100
>>
>>
>> If you all have some suggestions on this, Id like to hear them.
>> And of course, any other testing you'd like too.
>>
>>
>>> Hope this helps to get native Linux support for 8361p.
>> hear hear.
>> FWIW,  I pulled this card out of a dead Netgear WNR854T,
>> which is linux based (and GPL compliant)
>>
>>> Regards,
>>> - Sedat -
>>>
>>> P.S.: BTW, only to clarify it should be "e_n_i" as short-form for
>>> /etc/network/interfaces file, but e_n_a sounds more female and nicer
>>> :-).
>> I caught that, but it wasnt worth "correcting" ;-)
>>
>> thanks
>> Jim
> Unfortunately, [1] says not much about debugging.
> Anyway, Lennert has some new informations.
> Let's see what the experts will say.
>
> - Sedat -
>
> [1] http://wireless.kernel.org/en/users/Drivers/mwl8k
>

ok, as far as i can see for now, it looks like the actual solution is 
ignoring/rejecting any manual command to set parameters, neither 
iwconfig nor iw will change any settings. wpa_sup brings the card up and 
does also WPA2 but nothing else is tuneable thus a connection via 1Mb/s.

attaching a tarball from the results of the script which produced 42 
files of output.




--------------090609030401090305070906
Content-Type: application/x-xz;
 name="sedatscript.tar.xz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="sedatscript.tar.xz"

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
AAAABFla
--------------090609030401090305070906--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
