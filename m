From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/3] ifb: make device count build-time configurable
Date: Tue, 12 Jan 2016 16:35:37 +0100
Message-ID: <56951D49.5020800@iogearbox.net>
References: <1452599804-27284-1-git-send-email-lkundrak@v3.sk> <5695199E.2040303@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5695199E.2040303@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2016 04:19 PM, Daniel Borkmann wrote:
> On 01/12/2016 12:56 PM, Lubomir Rintel wrote:
>> The devices can be created at run-time for quite some time already and the
>> load-time device creation collides with attempts to create the device of
>> the same name:
>>
>>    # rmmod ifb
>>    # ip link add ifb0 type ifb
>>    RTNETLINK answers: File exists
>>
>> This is pretty much the same situation as was with the block loop devices
>> which was solved by adding a build-time configuration that the
>> distributions could use as they deem fit while keeping the default for
>> compatibility.
>>
>> Let's do that here as well.
>
> Thanks for the set in general, good to see it fixed!
>
>> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
>> ---
> [...]
>> +config IFB_COUNT
>> +        int "Number of ifb devices to pre-create at init time"
>> +        depends on IFB
>> +        default 3
>
> Should that not be 2?
>
>> +        help
>> +          Static number of ifb devices to be unconditionally pre-created
>> +          at init time.
>> +
>> +          This default value can be overwritten on the kernel command
>> +          line or with module-parameter ifb.numifbs.
>> +
>> +          The historic default is 3. If a mid-2007 version of iproute2
>> +          is used (v2.6.23 or later), it can be set to 0, since needed
>> +          ifb devices can be dynamically allocated via rtnetlink.
>
> [...]
>> -static int numifbs = 2;
>                ^^^^^^^^^^^^
>> +static int numifbs = CONFIG_IFB_COUNT;
>>   module_param(numifbs, int, 0);
>>   MODULE_PARM_DESC(numifbs, "Number of ifb devices");

Btw, perhaps there should also be a pr_info() or the like to warn the user
that relying on modprobe creating these devs is deprecated and scheduled
for removal in future, so they should switch to ip link instead ...
