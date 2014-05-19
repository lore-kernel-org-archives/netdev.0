From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] isdn: hisax: l3dss1.c: Fix for possible null pointer dereference
Date: Mon, 19 May 2014 23:18:36 +0200
Message-ID: <CAFo99gZwnvtResqq12LJk-g0AVrZDwyAjOehvWhEnHkUx6o42g@mail.gmail.com>
References: <1400347101-25476-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<20140518.211237.1637671513066247487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140518.211237.1637671513066247487.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Ahh, yes. That's niecer..
I am sending a new patch. If it is as you intended, I do the same with
the l3ni1.c file.


Best regards
Rickard Strandqvist


2014-05-19 3:12 GMT+02:00 David Miller <davem@davemloft.net>:
> From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> Date: Sat, 17 May 2014 19:18:21 +0200
>
>> There is otherwise a risk of a possible null pointer dereference.
>>
>> Was largely found by using a static code analysis program called cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>  ...
>
>> @@ -2208,8 +2208,12 @@ static int l3dss1_cmd_global(struct PStack *st, isdn_ctrl *ic)
>>                               { free_invoke_id(st, id);
>>                                       return (-2);
>>                               }
>> -                     pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
>> -                     pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
>> +
>> +                     if (pc)
>> +                     {
>> +                             pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
>> +                             pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
>> +                     }
>
> I think rather the intention was to put these pc-> assignments in the
> timeout > 0 code block.
