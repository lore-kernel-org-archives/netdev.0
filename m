From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 2/2] x86: get more exact nr_irqs
Date: Mon, 4 Jan 2010 11:03:02 -0800
Message-ID: <86802c441001041103s5abd6d3ai4e6ccbfc68323f3c@mail.gmail.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>
	 <4B398ECD.1080506@kernel.org>
	 <4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
	 <4B415E73.1050801@kernel.org> <4B41918D.3000605@kernel.org>
	 <m1fx6lizc3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753870Ab0ADTDR@vger.kernel.org>
In-Reply-To: <m1fx6lizc3.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 4, 2010 at 8:55 AM, Eric W. Biederman <ebiederm@xmission.co=
m> wrote:
> Yinghai Lu <yinghai@kernel.org> writes:
>
>> first check with NR_VECTORS - FIRST_EXTERNAL_VECTOR - 0x20
>> aka minus exceptions and system vectors.
>>
>> NR_CPUS =3D 512, and nr_cpu_ids =3D 128
>> will have NR_IRQS =3D 256 + 512 * 64 =3D 33024
>>
>> assume we have 20 intel ixgbe 6 port cards (with sriov and ixgbevf)
>> =A0 =A0 =A0 20 * 6 * 64 * 3 =3D 23040
>>
>> first will get:
>> =A0 =A0 =A0 128 * (256 - 64) =3D 24576
>> then with nr_irqs_gsi will get
>> =A0 =A0 =A0 (120 + 8 * 128 + 120 * 256) =3D 31864
>>
>> so 24576 will be used for nr_irqs.
>>
>> 24576 * 8 =3D 196608 bytes will be used for irq_desc_ptrs[]
>>
>> before this patch:
>> =A0 =A0 have nr_irqs =3D 120 + 8 * 128 + 120 * 64 =3D 8824
>> =A0 =A0 =A0 and irq_desc_ptrs[] is 70592
>>
>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>
> I am lost. =A0 =A0arch_probe_nr_irqs appears to be total nonsense.
>
> We have three concepts.
> - The number of irq sources we can talk about. =A0( nr_irqs)
> - The number of irqs we can possibly service. =A0 ((NR_VECTORS - 0x30=
) *nr_cpu_ids)
> - The number of irqs we actually connected up to cards in the
> =A0system that we need to do something with.
>
> Why do we need to allocate arrays at all?
>

irq_desc is allocated dynamically.

but irq_desc_ptrs is pointer array, it need to be allocated after
nr_irqs is probed.

YH
