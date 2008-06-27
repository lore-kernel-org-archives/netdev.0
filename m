From: "Michael Grollman" <mgrollman@nscus.com>
Subject: RE: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another Problem)
Date: Thu, 26 Jun 2008 21:44:42 -0700
Message-ID: <006701c8d810$85603410$860aa8c0@MICHAEL1>
References: <4861800B.90703@nscus.com> <20080625213142.GA29890@electric-eye.fr.zoreil.com> <48640535.2050000@nscus.com> <20080626215918.GC2555@electric-eye.fr.zoreil.com> <20080627023523.GD7703@parisc-linux.org> <006001c8d801$b02daf10$860aa8c0@MICHAEL1> <E6FF208A16840D4EBAA31D261B15A506011CAF92@ausx3mpc121.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0068_01C8D7D5.D9015C10"
Cc: <netdev@vger.kernel.org>, <lkml@metanurb.dk>,
	<akpm@linux-foundation.org>, <linux-pci@vger.kernel.org>
To: <Mario_Limonciello@Dell.com>, <matthew@wil.cx>,
	<romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp201.sat.emailsrvr.com ([66.216.121.201]:60319 "EHLO
	smtp201.sat.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbYF0Eol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 00:44:41 -0400
In-Reply-To: <E6FF208A16840D4EBAA31D261B15A506011CAF92@ausx3mpc121.aus.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------=_NextPart_000_0068_01C8D7D5.D9015C10
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit



I can pass additionally on the following observation, if it helps some more
clever than I:

In a boot where the RTL8102 is going to work, just prior to DHCP initiation
in the boot process, it will print:

	r8169: eth0: link up
	r8169: eth0: link up

Exactly twice.

Whereas, in any boot where it is on the road to failure, it will print it
exactly once:

	r8169: eth0: link up

No idea what it means, but the observation is very consistent.  The dmesg
log also supports this.  I attach a dmesg.gz log from a successful
2.5.26-rc8 boot, with eth0 working, to support this observation.

-Michael

-----Original Message-----
From: Mario_Limonciello@Dell.com [mailto:Mario_Limonciello@Dell.com] 
Sent: Thursday, June 26, 2008 8:25 PM
To: mgrollman@nscus.com; matthew@wil.cx; romieu@fr.zoreil.com
Cc: netdev@vger.kernel.org; lkml@metanurb.dk; akpm@linux-foundation.org;
linux-pci@vger.kernel.org
Subject: RE: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
Problem)

This is *not* just specific to your hardware.  I've encountered it on two
other platforms that have RTL8102's.  I posted some comments in another
thread the other day.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of mgrollman@nscus.com
Sent: Thursday, June 26, 2008 9:58 PM
To: 'Matthew Wilcox'; 'Francois Romieu'
Cc: netdev@vger.kernel.org; 'Kasper Sandberg'; akpm@linux-foundation.org;
linux-pci@vger.kernel.org
Subject: RE: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
Problem)

Matthew,

The only remedy I have found to date is a system reboot, sometimes a soft
one will work, sometimes a full power down is needed.  It may take a few
boots to get it happy.  If I can get it to boot with the Realtek working OK,
the system does not seem to fail, even after hours of use.  So either it
comes up working, or it does not.

But I am open to any ideas to try and correct!  I have an extra motherboard
around, if you guys think it may be in this particular unit's hardware.

- Michael


-----Original Message-----
From: Matthew Wilcox [mailto:matthew@wil.cx]
Sent: Thursday, June 26, 2008 7:35 PM
To: Francois Romieu
Cc: Michael Grollman; netdev@vger.kernel.org; Kasper Sandberg;
akpm@linux-foundation.org; linux-pci@vger.kernel.org
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
Problem)

On Thu, Jun 26, 2008 at 11:59:18PM +0200, Francois Romieu wrote:
> (linux-pci Cced)
> 
> Michael Grollman <mgrollman@nscus.com> :
> [...]
> > Per instructions, I built an 2.6.26-rc8 system on the target Intel 
> > hardware, and was able to re-recreate the intermittent failure of
the
8201.
> >  When in failure mode, the lspci -vx' display of the pci registers 
> > of the
> > 8102 is as follows:
> >
> > 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
> > RTL8101E PCI Express Fast Ethernet controller (rev ff) (prog-if ff)
> >    !!! Unknown header type 7f
> > 00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

Mmm.  All f's means that the device has fallen off the bus.  Nothing is
responding when we ask the device about it's config space.  What do you do
to get this device into this state?

--
Intel are signing my paycheques ... these opinions are still mine "Bill,
look, we understand that you're interested in selling us this operating
system, but compare it to ours.  We can't possibly take such a retrograde
step."

--
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html

------=_NextPart_000_0068_01C8D7D5.D9015C10
Content-Type: application/x-gzip;
	name="dmesg-2.6.26r8.realtek-working.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="dmesg-2.6.26r8.realtek-working.gz"

H4sICBQDZEgAA2RtZXNnLTIuNi4yNnI4LnJlYWx0ZWstd29ya2luZwDlO2tz4kiS3/UrMnb3wjAH
WCrxsu68Mbxsc21sxuDujvV1cEIqgdZC0uhh4/n1l1klhGiD2/h67sOdOxr0yMzKyszKVxWzyV1v
dvv5DkrzNAYV8HPmRr/j1cIL5qYnbhjYjkf/y0qnNx4aMLyZzg4gnhURz2DpLpbg8Se+xb37TYU0
5jbMXyB44lHk2ry2fcneenm25+XAN+ee6y+gMx72YBXY3AC48MykBnAf0wsNhqe34nWsyCdEEEqj
Tn9aBieIYDIagxX4jrtIIzNxAx9cH5+vxLXS8bzAwktEHPeGEPE4SCOLxxAnZiQemwnoqvyD0sIM
DWDZrWFnF2VlPDLgji/cOOERTsIPYvOJw4qvgujFAHX713aITrX4yKSP91MQ4LsU+HEU+CsKmnoE
Bc1psMYuBXpkH0Vhbr+iYGnHUGg21e8pNJ2jZtF09NcUiITSTV0vQdP6I/C5h3RiNBn4B95AENk8
qqAlzl3PTV5gEQVpSFYS+GiS0yAxPQjNBY8N0Fir1WTKJx4hEbTA1cr0bUBrRhuOgiA5P7X502ls
z5myMsMQORVGngTg4N+cWCs5nGcGloEMb4tAZgZkZUD5cnHMOIGL8T2IqdO4aNhJEPFarQY2TqSw
tFJ/ZcaPSHsyHPUFEl9bPBQrJU7DMIiSLdbQdxPX9Nw/CLM3vv8rinvYh6UZLyFBghy4n0QuzZ+p
9TaUhMBQGFoF2toZw+Wd8Lis9HnCrQQH1RpnzZrW0mB09QeEUYBLLw6imtIL/DjwUFRW4OGKhM+X
nX+FtrpmDcWSr+AhSV7UbzggjWsjSRz5BSzTWvK9DDUbDb2Zc9SsAGsyrV7fsDT00b1UD6PrrNXc
TqhRAU3X1FY+o1FmXw1VZ2r78bShNfDtI5hPpusJSiUcDR88bgzC5khDZQSE2uHRE7dRSI32I9hm
YlZIgI9oeG5SAfVReFu04bLy5EZJimaW0ZF2DZ75EqSJoQD+Oe4azQUAjX1NVtLKzJxuhIEjTAn0
BoPHbllghI8CIcNoq+oWQ9oWYdTVs2aO8bQyyXMKDJ6tnwyj5fDNGCgMGGUYXvCMvMoxrCKG7bTy
MXYwAGo0/QxDd9gGw1Lr0gMRBoop5woxSHYbDK3VbrUzDJ3zutYWGCjjIkbC15sxtC1XOTpIxQmM
3pJbj2T6rgPJ0o23FgvLwEc7jfExhy9jmCPfGBop2NAqQu26BEUhDFfT7SNa+LhjCF8BYRB4QtFi
ZdGigMDBD+FIcAhuyiCFRt5DiHkk45XNUekYNOk6cVc8gjjkluu4FvqXFEFwJNC1s3pNa0I3WASj
4XgCJS/85zmuupbaZmi1Qeonbxh9Q2PI6L0B1xho5dqilfCpQg/6mwes/imDYptHiPhJkbytnk0U
BsrBtZF0ssT52HFNIgz9hHuluzJ0kmBVmo7K5FQAmE66/RW0WlO9RMeArjwUblZlWx2cLL3kBOnG
SZRa5K7ITd1+qikXEecEQJHf9DAK+CiwJ5oOriMHX9pZ1tFDj4hrD1VDzg7Nq42LV1MGN53u9fDm
Er1tVbhbzE5ipVabDkeDOwOe0HMF0bm61jUwQ9fSzlVA5rRzJm7ZeVWje/pWfJ7MfHPF49C0UCpN
1pb+QrkZTHeiFBpSEqCvQ9e9cr0X0JrKTYBO10JvgAxSRuKgruxNwkSZWfISovFYLk5hQ0fBJMaA
C4KUsqU5oguXic9ZvXF5evmP0/Hp+BoGa7SsOAbpuBAOdR54HprRVTqHZzdZohHBaNS7vbkYXuah
QI4gU63dtEqwo4mca27GGHYsWhrKhCfCXNOQcirfNiN7N9XKZjToof0EwSMBDnpkL/1Jf7rJD3Eu
EfKLn7nDl29KGWMxTFSYaDDRYVKHSWOTk0pOs7hJvLlEKkrDJFsliwyQeLrDuAxdzD1xVT7gAwwv
JfIIBkVXknR2Y2hOTSU5I/8bfuBqPJhStog+kMvMcA/K76kbPRpCYygyta6qVbXecsDyTFzCIv0d
9q6aIos9vRwPb0+nvdsf02kQnYb+mg6RkCqbRqaPZhjh2oa5nGJ1S5TX1IIchrmM7qSMYCr8wsN/
zibdWY0kU5uN76bfjsQZ62z2McTB1w+OOPjKPoqov4F47fqP8HB986mDJkL+AXSoQwNaWBhpKvyi
aZgAlt9G7e5FlZjwi1oB242FadXeptP7ns4vBUJvo/Y/zv3gJ3F/8ZPoXH5cClevWfhli4pg6RrG
XroQmfSYou5EOh14UmtnLShZGMBscwVdCslK6GOROPbHshSlwP7Kafth0WnvIBjS0dPomefPsAW1
HRKpXyAy6U2G6KXn8Qs+WBXzCQVzBsqKsKwWgU6vYY7jBaZNMk3juYVh0CjwAz5/lm7SwagFdoTB
M8JEY+7E7wdfpvODwHJeBcLFoCKmSY4aNZK76GXIE/RtGA4pqUqKwsvmS35MM8ANKMlEV4fuDR1x
lmdW8VIX2S96yCD1qCpEL8jzxPttKtzW9IwKXX6cSn1LpfVxKu0tlfbHqZxtqZx9nIq1pfJx6TI1
p6J/nEq9kVM5++CMrIwR+4Nc8M1E3offJHzhRzYERBxfUyDHbBzRsIB4H6JIJNaUSRyJ2GwTYtPZ
hyhWpUyHjG2qYGGqAJhRYY7o28EzFvc0aVI/Ph4NRvlzzJCziqoqLoVUEGZ8N7gYTHtXBcBNC0bf
LtjCI4l4iBu2y802XOxyU3z+ioPty0Oj6P8Lo/DvJfs/HGVf0Cuq8QGTl+rf4RIDh4ZRTPRyK1So
l+kx+V+tJVndJPEeVqG+9ZLVm1ilZq68SJW6U836jwZnD73t4O39g7ePHpy9b3D9ob8d/Gz/4GdH
D65ngx+Hx3OJ/agmZMpwLCIif6PLJbo0my4Vq2AhqbfzHte0NwYeE4YbL3GEfQQkwsE+F5GYo6W9
A7deyXpuW1QDrnK0OK8fkZNSka2MZxpFXMpRsXIJioH/hyW0YhXaNe6KWi1uLBKjyFw5MbULqDER
5w0D8crOW8VMb7Q2DYNVvFj57tZHxpiPoNbO2m3FDSDGkeyUamc/CHZSu52XlvN7MRUq2dwxUy/Z
LS1VRvVdlyrRJ9fmQWYwH16HZhy7C3+Wl70z6kFlLYLRhJo6oSm72ZvNEA5jihATalpZ/KFI00BO
Mch9ezco+/bhNfwzGWfvZ5x9mHH9T2Bcfz/jes6464dpgu4veEZWu2mSYNJfurgoA1rvqeUhf6cC
RH7mhf8r8Ifxl7uLnNzE4zzM3/dGB8hpGbnX4A+T63H3W6GaQd5byDytysKyMMkxBLQ3MZMyVhWc
LdYyBrRZQz3V0Kmom+Lhb3dZ+w6dT+1Mhb8BA9EOqggvHi/NiLS36RlNnt2EliNpSuxfUhfKS0X/
SmgJv6kDqSqxGJIGNCBJXiYqtXZorxFTGQfjFe2BnkO9TMybIHjqKKSLsyPg55Ft0LjoHbKCTLn3
XdqdhBE6BreKxWYibgfVYX+QTVpxaR+0E8fpiuam67R3kiV5VB/GIXosUUKNMZegacX/lm+qis4e
4AVCnq/XyrB31TKAiFvbDmBJXbfVdtNQ16xlO9QipRxNK9OcRFSNvSApdqS0tyMuAhRzjYPhXjJD
GTPmjf8Csm+b7fs+u55HPh5zaZRlLBZkVGBfZLWb3Ef09nGS5ElH1f6oIxtzTJ1TaolfmNcgKdEa
RNxt9Uo4GBiUpW0a0OtX774QQIPpGEo70w6Wpr3+af8zvrgdSXVI0GUQJ7Ay1yTyOjybPm1u4TVr
NEpmmgTVJPV5GcOGJ/e9CKyAGZNmMBN/diMK7hRUbbFFRobpmK5He0Oeu3KFL6JxpJLRjO9xdrou
adH1qa5LU96MReaiyvlrDk1fc1oVssomWTvZpVYnmNmC+2j0lgGhx6mBm+L/vwiJz2iLkDrezl82
5hqaGERFP5YMLcyEaaKOPL4w0VEOJ51cL/EufVoWm/YvcXUhuLpoCc1TvK29Dd8S8K0ivJi+VFCD
fRWaQwXR1ymqUChK7Ki1H7vQo+QpX2i9gi4j2LoTvcZU6mCs6IaWy8KJafHSmPmm3ttmb9daBbNn
+l6zZ/qRgQapZoGGLy13trTsnXcGDK6QnSsyq21T/xAstWPuJ13hN7Y+uAIyhlEjGV/46WqOvGiH
iAjpyAWoycnI/JQ2u9G0/+A0DZ1tpJd17GWXes/sDg0jzqvoFaxgKUUT5SWzqKVyCIEmhtmUPMtB
sxKS0WoqdRWlvjUV+tyivZ86KZuaUZrx3cbGXzWwcJVi1udEwQrEHWVky3QOWhUHo4SNxqIHonm3
+6ot10C2onFBBhm74ihJEzrpIkVlqXVBRKtpcHIbcv/kex1C6Rb5L0NfRgECRiOmrp7pvYIdft+Q
e9IPtPgLMlP/FHPdZKLpHi2R5PaZ6wHYY8yVHSJSsCOxUSV7DUxtqxsTYMeYADtsAvkr9r0J/EAR
2kP3pxeoSPUNRWhHKEI7ThH6ISIi9py9VkQzV4R+jCL0w4rQP6qIP6NNYeclzj65sCMUwY5TxMEB
hSLarxVRzxVRP0YR9cOKqB9UBA2kVXU5I5GbyxSHaGQSlOcJcmdPuzGmbYtdbPYjRe60fJr7Fdk8
WpH6G4rUj1CkfpwiG4eICEU2XyuS5YpsHKPIxmFFNn6syPeNs3OkjMYZ4YxhkgQRNWxk8KKMPLZi
VwXUDu1z8VXqSbKUfb7GyjbOkJVqLJ8ZG+3J3TVMh9nuazqlIs7OIcEMFHUboy1gtjvnDp0ViS3T
92k/6phds80Qyis2s0SoQKSmjG/GaMWTU1YM5g/4VNVV3RhP2KcK3TjyZvRNJvZNFTP6Zl3qv6Ix
Ub4GaA9ttc7gU7cvs7PXsLuAnfuvhwCZsnLpCItgbRVQbZBJiY42Zoqg9J/ANi2DzlQeO6CVZNO6
Qmt55C/zgA6B7O0eMCU0bdrnM+DzsANj076mMzCUNm4MrLYfRDQWB/6Ccs5dcGoeWumczkUd0T1s
KXfj3g5IaoeQiFMUJCJZB9VeQSXWPqjsGAqWJ5MlPrdS8YrnrcfUF6efdw71GfIIoGxAZhIdroQC
LmVpBF+WHMFHQh175akrUVtrnsGluzDpTNogWdIQycY+WY1df6reUN2UNSAO+1EN/czupsHP8KOS
auZHJbPFFwaK5tEPnn0YdXpQYi1x/lkt7wX1A2qw1aBrokEgxeHNdF1TeLLEd3fTa4EhTJuTU1Sp
DhC9M8NSjXrDsLlxVq/A12EfWF2Os5mQmZiz0HXXxZ4GM/ItdVbTfhCBEPxdOd2BgUadMTzAWIUx
g7EGYx2O7U86edZBnlRDT7oZSjxgxQd4genZBOtp0WsQbQVN18Fa2aKLYrXBSjxxicXTfGWvTHFj
qllORxTYmxTULYV2kUK7QIEqNVHVV9sGfOn38H9TVbuDz5MqY/eTKakPYbSOqlV2htkia1qLaSqr
YxEoju3FCEidNdSpAdfdTr0NN73fqBUfJktQT3VW3iIX9idEmNlQJ3kB2pz4B303QtLVjjjuJo6U
0qzF3/c8C3Zh/JsBKnRuJqi+hiKrOTiJ7RMMIdyOIQ1tecKzWuzE0K8wxMmPFdpzYMdKbG95eIht
81thsg2NVWnXBZboaZ9NCl1y+lBCbjQmzti+JvAlcqnBjK4QoalcDxxnD9iI2ksT7sdi8xJ0kz6x
DD9EMDsTmjVhK0AnQF89tAMe+yd5dwD641tAoV/cd/4fzRRi6mPhh0YfbM84nSQxRQdb5EG2Gz9K
c1QPm+PtYFjF3IPBvYeBCQHiR9lDIO/PdsxRzEwtjDhHWZ+1UdrttyStqVpjI+jvsA8J+juwHUHP
pZRBbe+BzPveIoJthPsshkmWUZAulv83JoEWMCdbmJMtzBl96PRR30dvxyoiTB+eZBOZ7GNfFkyZ
LGVu6GCSH3Qx57ttIba/LcSODEfzPOYvbXNGv4awsMzIQj2lRp7wuZ3rXrPJKphRvYj+MrXS5SaA
qCK6w9sJFQeUd3uzyF8YcOFGK6nYUDT0YxDHxmyxFquB773UYOjAS5Ci2GkZBlER3Q7oGTXwib1s
P0Ee9ncxyc2J8yQNK6IEdZ0iPtElAItHiYkYyRITjhf6CUu2Q0NbyCY4qS+a+6ZXRL67uRRT3Zzq
X3I48YOZ87ycyXT2BALxyxyc8bR3O3vivh1Es8yRUDpC99Xs/lyVUM92kp20B7yFL2ZiLfvBAqZC
N1n8ecLIpENJV6udMKrSWfhyAVtuXpp0prhFvoq+7wS1TK+lzzITOkdd4eNuZzI4x+Kz3lSLZAqH
Emuw5GaUzLmZnOsiOkMJdS9+xnKu7j+wWchl9HclU4OvU1Z1YlRnRGUb7bWlvjyN7ovDARTZMSWI
UlHWAWdOjJmj2I+ksgbFiRmxbyYxX7lgh229ra2z1LlSTP4qaPjIIP3MiVq6CqCQXCxFsCB6oS53
nzRtQ5eGjODf5+L719h68ewaDvR3RGC1em29KQBEXEC8/+COA5dm9If7iHL9J+dYN41Sz6ZNQM55
W2WaNrOilzDZKUVNb4HjJ8sVnNzcX1+fKFJLVfErsojOgGHyZUC9puk1tSruMLVW1VZVU6tau5wr
CmsSXBKrqk3i/RVJozUTwz9Jsn8KFUrmpI/DMFrGuLtO2MxxPW8mfohTGATf6LikPZ4tTVyZBPyT
2BIFCg4vqg+Pzhqn4f6HP6xFVcULKLLLzU0MRO4TbbEN1uhkyQRjJWf1v/wkxEwSM8YYdIx1WPPl
5w1cfFbKtuc2yQe6KIQtZ0USFlDD8VNTnjKKxI+PYu4nyn8D1IQwMkw8AAA=

------=_NextPart_000_0068_01C8D7D5.D9015C10--

