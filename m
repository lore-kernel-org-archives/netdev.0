From: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Thu, 08 Mar 2012 13:18:08 -0800
Message-ID: <4F592210.1030003@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F579A88.6030503-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/07/2012 09:27 AM, Felix Fietkau wrote:
> On 2012-03-07 4:24 PM, Justin P. Mattock wrote:
>> On 03/07/2012 07:19 AM, Mohammed Shafi wrote:
>>> On Wed, Mar 7, 2012 at 7:55 PM, Justin P. Mattock
>>> <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>   wrote:
>>>> ath9k craps out from time to time(more annoying if anything)
>>>>
>>>> [44309.840830] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44309.858246] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44309.858255] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44309.932801] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44309.950352] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44309.950361] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.024301] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.041641] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44310.041646] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.116316] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.133909] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44310.133918] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.208021] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.225752] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
>>>> [44310.225761] ath: Could not stop RX, we could be confusing the DMA engine
>>>> when we start RX up
>>>> [44310.299922] ath: Failed to stop TX DMA, queues=0x001!
>>>> [44310.317579] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>>>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
>>>> [44310.317587] ath: Could not stop RX, we could be confusing the DMA engine
>>>> whe
>>>
>>> this is has become a know issue but less harmful, please try to see if
>>> the workaround of disabling power save helps
>>>
>>> iw dev wlanX set power_save off
>>>
>>
>> ok! I have set that on the machine.. will see if I get this message in
>> the upcoming weeks.
> Also, please try this patch with powersave enabled:
> http://nbd.name/ps-fix.patch
>
> - Felix
>


probably to early to tell if this patch is working or not(since this bug 
is shows up randomly), but I have applied this to the current Mainline 
and am so far not seeing the DMA failed to stop
as for any issues: waking up from suspend I get no 
connection(rmmod/modprobe recovers this) then after a few suspends the 
connection is real crappy(on and offline).

dmesg with debug gives me this:

[ 8804.908128] ath: PDADC (0,   0): a2f0 68686868
[ 8804.908132] ath: PDADC: Chain 0 | PDADC 112 Value 104 | PDADC 113 
Value 104 | PDADC 114 Value 104 | PDADC 115 Value 104 |
[ 8804.908137] ath: PDADC (0,   0): a2f4 68686868
[ 8804.908141] ath: PDADC: Chain 0 | PDADC 116 Value 104 | PDADC 117 
Value 104 | PDADC 118 Value 104 | PDADC 119 Value 104 |
[ 8804.908145] ath: PDADC (0,   0): a2f8 68686868
[ 8804.908149] ath: PDADC: Chain 0 | PDADC 120 Value 104 | PDADC 121 
Value 104 | PDADC 122 Value 104 | PDADC 123 Value 104 |
[ 8804.908154] ath: PDADC (0,   0): a2fc 68686868
[ 8804.908158] ath: PDADC: Chain 0 | PDADC 124 Value 104 | PDADC 125 
Value 104 | PDADC 126 Value 104 | PDADC 127 Value 104 |
[ 8804.908506] ath: Getting spur idx:0 is2Ghz:1 val:8000
[ 8804.908609] ath: Enable MIB counters
[ 8804.908632] ath: ANI parameters:
[ 8804.908635] ath: noiseImmunityLevel=0, spurImmunityLevel=7, 
ofdmWeakSigDetectOff=1
[ 8804.908638] ath: cckWeakSigThreshold=0, firstepLevel=0, listenTime=0
[ 8804.908641] ath: ofdmPhyErrCount=0, cckPhyErrCount=0
[ 8804.908643]
[ 8804.908646] ath: Writing ofdmbase=12582412   cckbase=12582712
[ 8804.908669] ath: New interrupt mask 0xf4041071
[ 8804.908672] ath: new IMR 0x918414b0
[ 8804.908679] ath: enable IER
[ 8804.908690] ath: AR_IMR 0x918414b0 IER 0x1
[ 8804.945518] ath: disable IER
[ 8804.945554] ath: enable IER
[ 8804.945565] ath: AR_IMR 0x918414b0 IER 0x1
[ 8805.031114] ath: Set channel: 2422 MHz type: 0
[ 8805.031243] ath: disable IER
[ 8805.031380] ath: Disable MIB counters
[ 8805.031425] ath: Reset to 2422 MHz, HT40: 0 fastcc: 0
[ 8805.031441] ath: NF calibrated [ctl] [chain 0] is -114
[ 8805.033988] ath: PDADC (0,   0): a280 04030201
[ 8805.033995] ath: PDADC: Chain 0 | PDADC   0 Value   1 | PDADC   1 
Value   2 | PDADC   2 Value   3 | PDADC   3 Value   4 |
[ 8805.034002] ath: PDADC (0,   0): a284 08070605
[ 8805.034007] ath: PDADC: Chain 0 | PDADC   4 Value   5 | PDADC   5 
Value   6 | PDADC   6 Value   7 | PDADC   7 Value   8 |
[ 8805.034013] ath: PDADC (0,   0): a288 0c0b0a09
[ 8805.034019] ath: PDADC: Chain 0 | PDADC   8 Value   9 | PDADC   9 
Value  10 | PDADC  10 Value  11 | PDADC  11 Value  12 |
[ 8805.034025] ath: PDADC (0,   0): a28c 100f0e0d
[ 8805.034030] ath: PDADC: Chain 0 | PDADC  12 Value  13 | PDADC  13 
Value  14 | PDADC  14 Value  15 | PDADC  15 Value  16 |
[ 8805.034037] ath: PDADC (0,   0): a290 18161412
[ 8805.034042] ath: PDADC: Chain 0 | PDADC  16 Value  18 | PDADC  17 
Value  20 | PDADC  18 Value  22 | PDADC  19 Value  24 |
[ 8805.034048] ath: PDADC (0,   0): a294 23201d1a
[ 8805.034053] ath: PDADC: Chain 0 | PDADC  20 Value  26 | PDADC  21 
Value  29 | PDADC  22 Value  32 | PDADC  23 Value  35 |
[ 8805.034059] ath: PDADC (0,   0): a298 302b2825
[ 8805.034064] ath: PDADC: Chain 0 | PDADC  24 Value  37 | PDADC  25 
Value  40 | PDADC  26 Value  43 | PDADC  27 Value  48 |
[ 8805.034070] ath: PDADC (0,   0): a29c 45403b36
[ 8805.034075] ath: PDADC: Chain 0 | PDADC  28 Value  54 | PDADC  29 
Value  59 | PDADC  30 Value  64 | PDADC  31 Value  69 |
[ 8805.034081] ath: PDADC (0,   0): a2a0 5a544f4a
[ 8805.034086] ath: PDADC: Chain 0 | PDADC  32 Value  74 | PDADC  33 
Value  79 | PDADC  34 Value  84 | PDADC  35 Value  90 |
[ 8805.034092] ath: PDADC (0,   0): a2a4 726c6660
[ 8805.034098] ath: PDADC: Chain 0 | PDADC  36 Value  96 | PDADC  37 
Value 102 | PDADC  38 Value 108 | PDADC  39 Value 114 |
[ 8805.034104] ath: PDADC (0,   0): a2a8 0f0d0b09
[ 8805.034110] ath: PDADC: Chain 0 | PDADC  40 Value   9 | PDADC  41 
Value  11 | PDADC  42 Value  13 | PDADC  43 Value  15 |
[ 8805.034116] ath: PDADC (0,   0): a2ac 17151311
[ 8805.034121] ath: PDADC: Chain 0 | PDADC  44 Value  17 | PDADC  45 
Value  19 | PDADC  46 Value  21 | PDADC  47 Value  23 |
[ 8805.034127] ath: PDADC (0,   0): a2b0 201d1b19
[ 8805.034133] ath: PDADC: Chain 0 | PDADC  48 Value  25 | PDADC  49 
Value  27 | PDADC  50 Value  29 | PDADC  51 Value  32 |
[ 8805.034139] ath: PDADC (0,   0): a2b4 2b282522
[ 8805.034145] ath: PDADC: Chain 0 | PDADC  52 Value  34 | PDADC  53 
Value  37 | PDADC  54 Value  40 | PDADC  55 Value  43 |
[ 8805.034151] ath: PDADC (0,   0): a2b8 3935312e
[ 8805.034156] ath: PDADC: Chain 0 | PDADC  56 Value  46 | PDADC  57 
Value  49 | PDADC  58 Value  53 | PDADC  59 Value  57 |
[ 8805.034163] ath: PDADC (0,   0): a2bc 4b44403c
[ 8805.034168] ath: PDADC: Chain 0 | PDADC  60 Value  60 | PDADC  61 
Value  64 | PDADC  62 Value  68 | PDADC  63 Value  75 |
[ 8805.034174] ath: PDADC (0,   0): a2c0 67605952
[ 8805.034179] ath: PDADC: Chain 0 | PDADC  64 Value  82 | PDADC  65 
Value  89 | PDADC  66 Value  96 | PDADC  67 Value 103 |
[ 8805.034185] ath: PDADC (0,   0): a2c4 7575756e
[ 8805.034190] ath: PDADC: Chain 0 | PDADC  68 Value 110 | PDADC  69 
Value 117 | PDADC  70 Value 117 | PDADC  71 Value 117 |
[ 8805.034196] ath: PDADC (0,   0): a2c8 75757575
[ 8805.034202] ath: PDADC: Chain 0 | PDADC  72 Value 117 | PDADC  73 
Value 117 | PDADC  74 Value 117 | PDADC  75 Value 117 |
[ 8805.034208] ath: PDADC (0,   0): a2cc 75757575
[ 8805.034213] ath: PDADC: Chain 0 | PDADC  76 Value 117 | PDADC  77 
Value 117 | PDADC  78 Value 117 | PDADC  79 Value 117 |
[ 8805.034219] ath: PDADC (0,   0): a2d0 75757575
[ 8805.034224] ath: PDADC: Chain 0 | PDADC  80 Value 117 | PDADC  81 
Value 117 | PDADC  82 Value 117 | PDADC  83 Value 117 |
[ 8805.034230] ath: PDADC (0,   0): a2d4 75757575
[ 8805.034236] ath: PDADC: Chain 0 | PDADC  84 Value 117 | PDADC  85 
Value 117 | PDADC  86 Value 117 | PDADC  87 Value 117 |
[ 8805.034241] ath: PDADC (0,   0): a2d8 75757575
[ 8805.034246] ath: PDADC: Chain 0 | PDADC  88 Value 117 | PDADC  89 
Value 117 | PDADC  90 Value 117 | PDADC  91 Value 117 |
[ 8805.034252] ath: PDADC (0,   0): a2dc 75757575
[ 8805.034257] ath: PDADC: Chain 0 | PDADC  92 Value 117 | PDADC  93 
Value 117 | PDADC  94 Value 117 | PDADC  95 Value 117 |
[ 8805.034264] ath: PDADC (0,   0): a2e0 75757575
[ 8805.034269] ath: PDADC: Chain 0 | PDADC  96 Value 117 | PDADC  97 
Value 117 | PDADC  98 Value 117 | PDADC  99 Value 117 |
[ 8805.034275] ath: PDADC (0,   0): a2e4 75757575
[ 8805.034281] ath: PDADC: Chain 0 | PDADC 100 Value 117 | PDADC 101 
Value 117 | PDADC 102 Value 117 | PDADC 103 Value 117 |
[ 8805.034286] ath: PDADC (0,   0): a2e8 75757575
[ 8805.034292] ath: PDADC: Chain 0 | PDADC 104 Value 117 | PDADC 105 
Value 117 | PDADC 106 Value 117 | PDADC 107 Value 117 |
[ 8805.034298] ath: PDADC (0,   0): a2ec 75757575
[ 8805.034303] ath: PDADC: Chain 0 | PDADC 108 Value 117 | PDADC 109 
Value 117 | PDADC 110 Value 117 | PDADC 111 Value 117 |
[ 8805.034310] ath: PDADC (0,   0): a2f0 75757575
[ 8805.034315] ath: PDADC: Chain 0 | PDADC 112 Value 117 | PDADC 113 
Value 117 | PDADC 114 Value 117 | PDADC 115 Value 117 |
[ 8805.034321] ath: PDADC (0,   0): a2f4 75757575
[ 8805.034326] ath: PDADC: Chain 0 | PDADC 116 Value 117 | PDADC 117 
Value 117 | PDADC 118 Value 117 | PDADC 119 Value 117 |
[ 8805.034332] ath: PDADC (0,   0): a2f8 75757575
[ 8805.034338] ath: PDADC: Chain 0 | PDADC 120 Value 117 | PDADC 121 
Value 117 | PDADC 122 Value 117 | PDADC 123 Value 117 |
[ 8805.034344] ath: PDADC (0,   0): a2fc 75757575
[ 8805.034349] ath: PDADC: Chain 0 | PDADC 124 Value 117 | PDADC 125 
Value 117 | PDADC 126 Value 117 | PDADC 127 Value 117 |
[ 8805.034377] ath: Getting spur idx:0 is2Ghz:1 val:8000
[ 8805.036119] ath: Reset TX queue: 0
[ 8805.036125] ath: tx ok 0x0 err 0x0 desc 0x10f eol 0x10f urn 0x0
[ 8805.036130] ath: Reset TX queue: 1
[ 8805.036135] ath: tx ok 0x0 err 0x0 desc 0x10f eol 0x10f urn 0x0
[ 8805.036140] ath: Reset TX queue: 2
[ 8805.036146] ath: tx ok 0x0 err 0x0 desc 0x10f eol 0x10f urn 0x0
[ 8805.036151] ath: Reset TX queue: 3
[ 8805.036157] ath: tx ok 0x0 err 0x0 desc 0x10f eol 0x10f urn 0x0
[ 8805.036163] ath: Reset TXQ, inactive queue: 4
[ 8805.036167] ath: Reset TXQ, inactive queue: 5
[ 8805.036171] ath: Reset TXQ, inactive queue: 6
[ 8805.036175] ath: Reset TXQ, inactive queue: 7
[ 8805.036180] ath: Reset TX queue: 8
[ 8805.036195] ath: tx ok 0x0 err 0x0 desc 0x10f eol 0x10f urn 0x0
[ 8805.036201] ath: Reset TX queue: 9
[ 8805.036216] ath: tx ok 0x0 err 0x0 desc 0x10f eol 0x10f urn 0x0
[ 8805.036230] ath: ah->misc_mode 0x4
[ 8805.037647] ath: Running PA Calibration
[ 8805.038316] ath: enabling ADC Gain Calibration
[ 8805.038320] ath: enabling ADC DC Calibration
[ 8805.038324] ath: enabling IQ Calibration
[ 8805.038333] ath: starting ADC Gain Calibration
[ 8805.038471] ath: Enable MIB counters
[ 8805.038496] ath: ANI parameters:
[ 8805.038501] ath: noiseImmunityLevel=0, spurImmunityLevel=7, 
ofdmWeakSigDetectOff=1
[ 8805.038507] ath: cckWeakSigThreshold=0, firstepLevel=2, listenTime=0
[ 8805.038511] ath: ofdmPhyErrCount=0, cckPhyErrCount=0
[ 8805.038513]
[ 8805.038521] ath: ANI parameters:
[ 8805.038525] ath: noiseImmunityLevel=0, spurImmunityLevel=7, 
ofdmWeakSigDetectOff=1
[ 8805.038531] ath: cckWeakSigThreshold=0, firstepLevel=2, listenTime=0
[ 8805.038536] ath: ofdmPhyErrCount=0, cckPhyErrCount=0
[ 8805.038538]
[ 8805.038543] ath: Writing ofdmbase=12582412   cckbase=12582712
[ 8805.038578] ath: New interrupt mask 0xf4041071
[ 8805.038583] ath: new IMR 0x918414b0
[ 8805.038592] ath: enable IER
[ 8805.038604] ath: AR_IMR 0x918414b0 IER 0x1
[ 8805.038695] ath: Set HW RX filter: 0x207
[ 8805.038724] ieee80211 phy5: device now idle
[ 8805.038826] ath: AWAKE -> FULL-SLEEP
[ 8805.038911] ath: FULL-SLEEP -> AWAKE
[ 8805.041787] ath: AWAKE -> FULL-SLEEP
[ 8805.041808] ieee80211 phy5: device no longer idle - working
[ 8805.041817] ath: FULL-SLEEP -> AWAKE
[ 8805.044666] wlan0: authenticate with 00:1e:2a:62:6b:1e (try 1)
[ 8805.044679] ath: transmitting packet, skb: f6b88c00
[ 8805.044688] ath: qnum: 0, txq depth: 0
[ 8805.044690] ath: TXDP[0] = 2ecd6e8c (eecd6e8c)
[ 8805.044692] ath: Enable TXE on queue: 0
[ 8805.242495] wlan0: authenticate with 00:1e:2a:62:6b:1e (try 2)
[ 8805.242511] ath: transmitting packet, skb: f71309c0
[ 8805.242521] ath: qnum: 0, txq depth: 1
[ 8805.242525] ath: link[0] (eecd6e8c)=2ecd6ef0 (eecd6ef0)
[ 8805.242528] ath: Enable TXE on queue: 0
[ 8805.441878] wlan0: authenticate with 00:1e:2a:62:6b:1e (try 3)
[ 8805.441893] ath: transmitting packet, skb: f6b88b40
[ 8805.441903] ath: qnum: 0, txq depth: 2
[ 8805.441907] ath: link[0] (eecd6ef0)=2ecd6f54 (eecd6f54)
[ 8805.441911] ath: Enable TXE on queue: 0
[ 8805.641298] wlan0: authentication with 00:1e:2a:62:6b:1e timed out
[ 8805.641445] ieee80211 phy5: device now idle


will continue running the system to see if I get anymore leads on this 
issue.

Justin P. Mattock



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
