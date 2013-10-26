From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 1/3] vxlan: silence one build warning
Date: Sat, 26 Oct 2013 15:06:04 +0800
Message-ID: <CAEH94Lia4VVU6Vnn_7DhOHo4yhR-tsMPu7biMCeSMgQPvkQrug@mail.gmail.com>
References: <1382687360-27794-1-git-send-email-zwu.kernel@gmail.com>
	<20131025084134.6cfa153a@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131025084134.6cfa153a@samsung-9>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 25, 2013 at 11:41 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 25 Oct 2013 15:49:18 +0800
> Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
>
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> drivers/net/vxlan.c: In function =91vxlan_sock_add=92:
>> drivers/net/vxlan.c:2298:11: warning: =91sock=92 may be used uniniti=
alized in this function [-Wmaybe-uninitialized]
>> drivers/net/vxlan.c:2275:17: note: =91sock=92 was declared here
>>   LD      drivers/net/built-in.o
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> ---
>>  drivers/net/vxlan.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 2ef5b62..e15f1af 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -2272,7 +2272,7 @@ static struct vxlan_sock *vxlan_socket_create(=
struct net *net, __be16 port,
>>  {
>>       struct vxlan_net *vn =3D net_generic(net, vxlan_net_id);
>>       struct vxlan_sock *vs;
>> -     struct socket *sock;
>> +     struct socket *sock =3D NULL;
>>       struct sock *sk;
>>       int rc =3D 0;
>>       unsigned int h;
>
> This only happens with certain versions of Gcc which have buggy depen=
dency
> analysis. It doesn't happen with Gcc 4.7, think it only shows up in 4=
=2E4.
> I would rather not fix the warning this way since it risks masking la=
ter bugs if this code ever changes.
Gcc version is 4.7.2 on my box, this warning took palce.
# gcc -v
Using built-in specs.
COLLECT_GCC=3Dgcc
=2E..
gcc version 4.7.2 20120921 (Red Hat 4.7.2-2) (GCC)


--=20
Regards,

Zhi Yong Wu
