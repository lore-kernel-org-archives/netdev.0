From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ipip: add module alias for tunl0 tunnel device
Date: Tue, 30 Nov 2010 15:55:15 +0800
Message-ID: <AANLkTi=DFN=r5XLYEwb3RYOyTF+u0uTEUa3wX5i2ijJZ@mail.gmail.com>
References: <20101129194746.724222156@vyatta.com> <20101129194805.851988995@vyatta.com>
 <1291101577.2725.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63898 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117Ab0K3Hzh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 02:55:37 -0500
Received: by fxm8 with SMTP id 8so900174fxm.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 23:55:36 -0800 (PST)
In-Reply-To: <1291101577.2725.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 3:19 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 29 novembre 2010 =E0 11:47 -0800, Stephen Hemminger a =E9cri=
t :
>> pi=E8ce jointe document texte brut (ipip-alias.patch)
>> If ipip is built as a module the 'ip tunnel add' command would fail =
because
>> the ipip module was not being autoloaded. =A0Adding an alias for
>> the tunl0 device name cause dev_load() to autoload it when needed.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> --- a/net/ipv4/ipip.c 2010-11-29 11:40:25.026277890 -0800
>> +++ b/net/ipv4/ipip.c 2010-11-29 11:41:05.790681069 -0800
>> @@ -913,3 +913,4 @@ static void __exit ipip_fini(void)
>> =A0module_init(ipip_init);
>> =A0module_exit(ipip_fini);
>> =A0MODULE_LICENSE("GPL");
>> +MODULE_ALIAS("tunl0");
>
> I am not sure I understand you...
>
> Here, I do have ipip built as a module, and I have no problem :
>
> # lsmod|grep ipip
> # ip tunnel add
> cannot determine tunnel mode (ipip, gre or sit)
> # lsmod|grep ipip
> # ip tunnel add mode ipip
> # lsmod|grep ipip
> ipip =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A07692 =A00
> tunnel4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2949 =A01 ipip
> #
>
> What am I missing ?
>
>

localhost linux # lsmod
Module                  Size  Used by
ipv6                  309359  12
localhost linux # ip -V
ip utility, iproute2-ss091226
localhost linux # ip tunnel add mode gre
ioctl: No such device
localhost linux # ip tunnel add mode ipip
ioctl: No such device
localhost linux # modprobe ip_gre
localhost linux # modprobe ipip
localhost linux # ip tunnel add mode ipip
localhost linux # ip tunnel add mode gre
localhost linux # lsmod
Module                  Size  Used by
ipip                    8128  0
tunnel4                 2683  1 ipip
ip_gre                 15055  0
gre                     1967  1 ip_gre
ipv6                  309359  13 ip_gre


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
