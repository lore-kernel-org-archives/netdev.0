From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qed: fix uninitialized data in aRFS intrastructure
Date: Thu, 11 May 2017 16:31:13 +0200
Message-ID: <CAK8P3a2x8OxcoHyx_e1Tj7k5QP5nVvTt3mh5WZvdfMfrZqPw8g@mail.gmail.com>
References: <20170511121633.3591880-1-arnd@arndb.de> <BLUPR0701MB2004E8FA50C46973E09FBA298DED0@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BLUPR0701MB2004E8FA50C46973E09FBA298DED0@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 11, 2017 at 4:03 PM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> register, which went subtly wrong due to the wrong size in a memset():
>>
>> ethernet/qlogic/qed/qed_init_fw_funcs.c: In function
>> 'qed_set_rfs_mode_disable':
>> ethernet/qlogic/qed/qed_init_fw_funcs.c:993:3: error: '*((void
>> *)&ramline+4)' is used uninitialized in this function [-Werror=uninitialized]
>>
>> This removes the silly loop and memset, and instead directly writes the
>> correct value to the register.
>
> Hi Arnd,
>
> For the most part - I'm almost all in favor of this change.
> But just to make it clear - the actual fix could have been a one-liner, right?
> The rest are style changes.

Correct. Having the correct length in the memset is a sufficient fix for
the warning, but it felt wrong to send it since the root of the problem
seems to be the complexity of the code that was hiding it.

>> +#define CAM_REG(pf_id) (PRS_REG_GFT_CAM + CAM_LINE_SIZE * (pf_id))
>> +#define RAM_REG(pf_id) (PRS_REG_GFT_PROFILE_MASK_RAM +
>
> Not sure I'm a huge fan of this specific style change;
> Seems like we could easily manage without these macros.

I tried first and ended up with really long lines that I did not like.

Generally speaking, feel free to treat any of my compile-time warning
fix patches as simple bug reports and apply a different fix that seems
more appropriate. I mainly send it in patch form since that seems to be
the quickest way to address any issues.

      Arnd
