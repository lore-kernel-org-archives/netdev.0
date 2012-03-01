From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH 1/3] netfilter: Fix copy_to_user too small size parametre.
Date: Thu, 1 Mar 2012 19:21:45 +0530
Message-ID: <CAOD=uF6GizMhTWkriQCnV7T_2vzOSQ85sG1ruoEi_YtNSK+9kQ@mail.gmail.com>
References: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120301101809.GA6488@1984>
	<CAOD=uF6yqCETUG8jMCmjYDM+L1DsM91OiRveONJkNxMf=skTSg@mail.gmail.com>
	<20120301130311.GA7429@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120301130311.GA7429@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Pablo for clarification.
I will resend the patch.


regards
santosh

On Thu, Mar 1, 2012 at 6:33 PM, Pablo Neira Ayuso <pablo@netfilter.org>=
 wrote:
> On Thu, Mar 01, 2012 at 04:15:05PM +0530, santosh prasad nayak wrote:
>> Hi Pablo.
>>
>> copy_to_user( dest, source, length)
>>
>> Normally, =A0'length' =A0is equal to =A0'sizeof (source) '.
>>
>> In this case "length" =A0 =3D =A0 32
>> =A0 =A0 =A0 =A0"sizeof(source)" =A0=3D =A0 29.
>>
>> Is it intentional ?
>
> ebtables expects 32 bytes names.
>
>> Won't it copy extra 3 bytes of kernel data to userspace ?
>
> You're right. We have to copy 29 bytes but we have to fill the
> remaining bytes with zeroes. I think something like:
>
> char name[EBT_FUNCTION_MAXNAMELEN] =3D {};
>
> /* user-space ebtables expects 32 bytes-long names, but xt_match uses
> =A0* 29 bytes for that. */
> sprintf(name, "%s", m->u.match->name);
> if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
> ...
>
> will resolve this issue.
>
> Would you resend a new patch?
