From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/net/wireless/ath/wil6210: Makefile, only -Werror
 when no -W* in EXTRA_CFLAGS
Date: Wed, 27 Feb 2013 16:56:57 +0800
Message-ID: <512DCA59.4040800@asianux.com>
References: <512DADCA.9040609@asianux.com> <1385870.TegBXpTM9i@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385870.TegBXpTM9i@lx-vladimir>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8827=E6=97=A5 16:45, Vladimir Kondratie=
v =E5=86=99=E9=81=93:
> On Wednesday, February 27, 2013 02:55:06 PM Chen Gang wrote:
>>
>>   When make with EXTRA_CFLAGS=3D-W, it will report error.
>>   so give a check in Makefile.
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>  drivers/net/wireless/ath/wil6210/Makefile |    4 +++-
>>  1 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/wireless/ath/wil6210/Makefile b/drivers/net=
/wireless/ath/wil6210/Makefile
>> index 9396dc9..d288eea 100644
>> --- a/drivers/net/wireless/ath/wil6210/Makefile
>> +++ b/drivers/net/wireless/ath/wil6210/Makefile
>> @@ -9,5 +9,7 @@ wil6210-objs +=3D wmi.o
>>  wil6210-objs +=3D interrupt.o
>>  wil6210-objs +=3D txrx.o
>> =20
>> -subdir-ccflags-y +=3D -Werror
>> +ifeq (, $(findstring -W,$(EXTRA_CFLAGS)))
>> +	subdir-ccflags-y +=3D -Werror
>> +endif
>>  subdir-ccflags-y +=3D -D__CHECK_ENDIAN__
>>
> Acked-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
>=20
> Well, agree; -W triggers lots of warnings, I suspect all other places=
 that use
> -Werror should be problematic. Worth fixing all others? Quick look fo=
r v3.8 raises:
>=20

  thank you for your suggestion.
  after this patch applied, I will do for others (let you as signed-of-=
by, too).

  :-)


> linux$ find . -name Makefile | xargs grep -e -Werror
> ./arch/sh/lib/Makefile:ccflags-y :=3D -Werror
> ./arch/sh/kernel/Makefile:ccflags-y :=3D -Werror
> ./arch/sh/mm/Makefile:ccflags-y :=3D -Werror
> ./arch/sh/cchips/hd6446x/Makefile:ccflags-y :=3D -Werror
> ./arch/sparc/prom/Makefile:ccflags :=3D -Werror
> ./arch/sparc/lib/Makefile:ccflags-y :=3D -Werror
> ./arch/sparc/kernel/Makefile:ccflags-y :=3D -Werror
> ./arch/sparc/mm/Makefile:ccflags-y :=3D -Werror
> ./arch/alpha/lib/Makefile:ccflags-y :=3D -Werror
> ./arch/alpha/oprofile/Makefile:ccflags-y :=3D -Werror -Wno-sign-compa=
re
> ./arch/alpha/mm/Makefile:ccflags-y :=3D -Werror
> ./arch/powerpc/kvm/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D =
-Werror
> ./arch/powerpc/lib/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D =
-Werror
> ./arch/powerpc/kernel/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D=
 -Werror
> ./arch/powerpc/oprofile/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) =
:=3D -Werror
> ./arch/powerpc/xmon/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D=
 -Werror
> ./arch/powerpc/mm/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D -=
Werror
> ./arch/powerpc/sysdev/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D=
 -Werror
> ./arch/powerpc/sysdev/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D=
 -Werror
> ./arch/powerpc/sysdev/xics/Makefile:subdir-ccflags-$(CONFIG_PPC_WERRO=
R) :=3D -Werror
> ./arch/powerpc/platforms/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR)=
 :=3D -Werror
> ./arch/powerpc/perf/Makefile:subdir-ccflags-$(CONFIG_PPC_WERROR) :=3D=
 -Werror
> ./Makefile:                -Werror-implicit-function-declaration \
> ./tools/perf/Makefile:  CFLAGS_WERROR :=3D -Werror
> ./tools/perf/Makefile:ifeq ($(call try-cc,$(SOURCE_HELLO),$(CFLAGS) -=
Werror -fstack-protector-all,-fstack-protector-all),y)
> ./tools/perf/Makefile:ifeq ($(call try-cc,$(SOURCE_HELLO),$(CFLAGS) -=
Werror -Wstack-protector,-Wstack-protector),y)
> ./tools/perf/Makefile:ifeq ($(call try-cc,$(SOURCE_HELLO),$(CFLAGS) -=
Werror -Wvolatile-register-var,-Wvolatile-register-var),y)
> ./drivers/scsi/lpfc/Makefile:ccflags-y +=3D -Werror
> ./drivers/scsi/aic7xxx/Makefile:ccflags-y +=3D -Werror
> ./drivers/staging/omapdrm/Makefile:ccflags-y :=3D -Iinclude/drm -Werr=
or
> ./drivers/net/wireless/ath/wil6210/Makefile:subdir-ccflags-y +=3D -We=
rror
>=20
>=20
>=20


--=20
Chen Gang

Asianux Corporation
