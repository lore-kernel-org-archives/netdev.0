From: Michal Bachraty <michal.bachraty-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv2] am33xx: cpsw: default to ethernet hwaddr from efuse if
 not defined in dt
Date: Fri, 18 Jan 2013 09:26:47 +0100
Message-ID: <CAAfrEwZ-SBiHpZqYRwEpcm-qkeb=S-nuzZyqaG5K2qqCcELqSQ@mail.gmail.com>
References: <1358461134-13452-1-git-send-email-jacmet@sunsite.dk>
 <50F8DA3A.3090406@ti.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9039664772836114278=="
Cc: michal.bachraty-6oiIBCxl0MMjD8S081q9vkEOCMrvLtNR@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <50F8DA3A.3090406-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

--===============9039664772836114278==
Content-Type: multipart/alternative; boundary=14dae9340a6957c3b804d38bdf94

--14dae9340a6957c3b804d38bdf94
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Jan 18, 2013 at 6:14 AM, Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org> wrote:

> On 1/18/2013 3:48 AM, Peter Korsgaard wrote:
>
>> When booting with CONFIG_ARM_APPENDED_DTB (either because of using an old
>> U-Boot, not wanting the hassle of 2 files or when using Falcon fast boot
>> mode in U-Boot), nothing updates the ethernet hwaddr specified for the
>> CPSW slaves, causing the driver to use a random hwaddr, which is some
>> times
>> troublesome.
>>
>> The am33xx has unique ethernet hwaddrs programmed in the efuse, so it
>> makes
>> more sense to default to these rather than random ones. Add a fixup step
>> which adds mac-address dt properties using the efuse addresses if the DTB
>> didn't contain valid ones.
>>
>> Signed-off-by: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
>>
>>
> This implementation looks fine.
> Acked-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
>
> Regards
> Mugunthan V N
>

Thanks,
My approach for cpsw driver is posted here:
https://patchwork.kernel.org/patch/1966481/
I added DT option mac-address-source because there is still possiblility to
have mac address set by the u-boot in the future. Beaglebone have special
eeprom on board, were you can have stored user MAC and u-boot can read
eeprom
data. Maybe some users will want this feature.  Also in cpsw dt binding
documentation, there is mention  /* Filled in by U-Boot */.  For that
purpose,
code I proposed can easily deal with any driver exteds.

Reading CPU mac address registers with (my approach) or without (your
approach) DT should be more discussed. Also your way seems to be fine.

--14dae9340a6957c3b804d38bdf94
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Jan 18, 2013 at 6:14 AM, Mugunth=
an V N <span dir=3D"ltr">&lt;<a href=3D"mailto:mugunthanvnm-l0cyMroinI0@public.gmane.org" target=
=3D"_blank">mugunthanvnm-l0cyMroinI0@public.gmane.org</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
<div class=3D"im">On 1/18/2013 3:48 AM, Peter Korsgaard wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
When booting with CONFIG_ARM_APPENDED_DTB (either because of using an old<b=
r>
U-Boot, not wanting the hassle of 2 files or when using Falcon fast boot<br=
>
mode in U-Boot), nothing updates the ethernet hwaddr specified for the<br>
CPSW slaves, causing the driver to use a random hwaddr, which is some times=
<br>
troublesome.<br>
<br>
The am33xx has unique ethernet hwaddrs programmed in the efuse, so it makes=
<br>
more sense to default to these rather than random ones. Add a fixup step<br=
>
which adds mac-address dt properties using the efuse addresses if the DTB<b=
r>
didn&#39;t contain valid ones.<br>
<br>
Signed-off-by: Peter Korsgaard &lt;<a href=3D"mailto:jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org" tar=
get=3D"_blank">jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org</a>&gt;<br>
<br>
</blockquote>
<br></div>
This implementation looks fine.<br>
Acked-by: Mugunthan V N &lt;<a href=3D"mailto:mugunthanvnm-l0cyMroinI0@public.gmane.org" target=
=3D"_blank">mugunthanvnm-l0cyMroinI0@public.gmane.org</a>&gt;<br>
<br>
Regards<span class=3D"HOEnZb"><font color=3D"#888888"><br>
Mugunthan V N<br>
</font></span></blockquote></div><br>Thanks,<br>My approach for cpsw driver=
 is posted here: <a href=3D"https://patchwork.kernel.org/patch/1966481/">ht=
tps://patchwork.kernel.org/patch/1966481/</a><br>I added DT option mac-addr=
ess-source because there is still possiblility to <br>
have mac address set by the u-boot in the future. Beaglebone have special <=
br>eeprom on board, were you can have stored user MAC and u-boot can read e=
eprom <br>data. Maybe some users will want this feature.=A0 Also in cpsw dt=
 binding <br>
documentation, there is mention=A0 /* Filled in by U-Boot */.=A0 For that p=
urpose, <br>code I proposed can easily deal with any driver exteds. <br><br=
>Reading CPU mac address registers with (my approach) or without (your <br>
approach) DT should be more discussed. Also your way seems to be fine. <br>

--14dae9340a6957c3b804d38bdf94--

--===============9039664772836114278==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============9039664772836114278==--
