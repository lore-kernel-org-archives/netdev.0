From: Ryan Hsu <ryanhsu@qti.qualcomm.com>
Subject: Re: WARN_ON_ONCE(work > weight) in napi_poll()
Date: Mon, 10 Jul 2017 21:24:39 +0000
Message-ID: <b418d63d-d348-90b5-ea58-6478a1a037f5@qca.qualcomm.com>
References: <26670dce-4dd2-f8e4-0e14-90d74257e739@virtuozzo.com>
 <87wp7oia6j.fsf@kamboji.qca.qualcomm.com>
 <952aefe1-6f6a-3978-e7e7-5e74076f26a3@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Networking <netdev@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <952aefe1-6f6a-3978-e7e7-5e74076f26a3@virtuozzo.com>
Content-Language: en-US
Content-ID: <B2B0AE3319A65944848DC3C7E0773828@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/04/2017 08:59 AM, Andrey Ryabinin wrote:

> On 07/04/2017 04:49 PM, Kalle Valo wrote:
>> Andrey Ryabinin <aryabinin@virtuozzo.com> writes:
>>
>>> I occasionally hit WARN_ON_ONCE(work > weight); in napi_poll() on a
>>> laptop with ath10k card.
>>>
>>>
>>> [37207.593370] ------------[ cut here ]------------
>>> [37207.593380] WARNING: CPU: 0 PID: 7 at ../net/core/dev.c:5274
>>> net_rx_action+0x258/0x360
>>> [37207.593381] Modules linked in: snd_hda_codec_realtek snd_soc_skl
>>> snd_hda_codec_generic snd_soc_skl_ipc snd_soc_sst_ipc snd_soc_sst_dsp
>>> snd_hda_ext_core snd_soc_sst_match snd_soc_core rtsx_pci_sdmmc
>>> mmc_core snd_pcm_dmaengine x86_pkg_temp_thermal snd_hda_intel uvcvideo
>>> kvm_intel videobuf2_vmalloc kvm snd_hda_codec snd_hwdep btusb
>>> videobuf2_memops btintel snd_hda_core videobuf2_v4l2 bluetooth
>>> irqbypass snd_pcm videobuf2_core crc32c_intel videodev mei_me mei
>>> rtsx_pci intel_lpss_pci intel_lpss_acpi intel_vbtn intel_lpss mfd_core
>>> tpm_tis intel_hid tpm_tis_core tpm efivarfs
>>> [37207.593430] CPU: 0 PID: 7 Comm: ksoftirqd/0 Not tainted 4.11.7 #28
>>> [37207.593432] Hardware name: Dell Inc. XPS 13 9360/0839Y6, BIOS 1.3.5 =
05/08/2017
>> What firmware and hardware versions exactly? The dmesg output when
>> ath10k loads is preferred. As you are using XPS 13 I'm guessing it's one
>> of QCA6174 family.
>>
> Yes it's qca6174.
>
> $ dmesg |grep ath10
> [    0.624828] ath10k_pci 0000:3a:00.0: enabling device (0000 -> 0002)
> [    0.626370] ath10k_pci 0000:3a:00.0: pci irq msi oper_irq_mode 2 irq_m=
ode 0 reset_mode 0
> [    0.837862] ath10k_pci 0000:3a:00.0: qca6174 hw3.2 target 0x05030000 c=
hip_id 0x00340aff sub 1a56:1535
> [    0.837863] ath10k_pci 0000:3a:00.0: kconfig debug 0 debugfs 1 tracing=
 0 dfs 0 testmode 0
> [    0.838388] ath10k_pci 0000:3a:00.0: firmware ver WLAN.RM.2.0-00180-QC=
ARMSWPZ-1 api 4 features wowlan,ignore-otp,no-4addr-pad crc32 75dee6c5
> [    0.900606] ath10k_pci 0000:3a:00.0: board_file api 2 bmi_id N/A crc32=
 19644295
> [    3.020681] ath10k_pci 0000:3a:00.0: htt-ver 3.26 wmi-op 4 htt-op 3 ca=
l otp max-sta 32 raw 0 hwcrypto 1
> [    9.574087] ath10k_pci 0000:3a:00.0 wlp58s0: renamed from wlan0
>

I can't reproduce of this past few days, not sure if this is due to the ams=
du packets received from AP, would you mind share what Ap you're using?
And if there any specific steps you're doing?

Also WLAN.RM.2.0-00180-QCARMSWPZ-1 firmware is a bit old, could you also up=
date firmware to give it a try?
https://github.com/kvalo/ath10k-firmware/tree/master/QCA6174/hw3.0/4.4

--=20
Ryan Hsu
