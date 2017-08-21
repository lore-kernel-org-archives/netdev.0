From: Bhumika Goyal <bhumirks@gmail.com>
Subject: Re: [PATCH 0/6] drivers: make device_attribute const
Date: Mon, 21 Aug 2017 18:27:31 +0530
Message-ID: <CAOH+1jGD1XSAqTHsq_9LEQKKMTNXA63f3vbB1cY9WR39WVh9tQ@mail.gmail.com>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com> <CAJZ5v0jo6q5mniU2HihHcOSqggZ8HFy3mtuo0vXYwuc2tLQ7=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Julia Lawall <julia.lawall@lip6.fr>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Len Brown <lenb@kernel.org>, jbacik@fb.com,
        Jiri Kosina <jikos@kernel.org>,
        Benjamin Tissoires <benjamin.tissoires@redhat.com>,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br,
        Darren Hart <dvhart@infradead.org>,
        Andy Shevchenko <andy@infradead.org>,
        Sebastian Reichel <sre@kernel.org>,
        ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net,
        linux-input@vger.kernel.org, netdev@vger.kernel.org,
        Platform Driver <platform-driver-x86@vger.kernel.org>,
        Linux PM <linux-pm@vg
To: "Rafael J. Wysocki" <rafael@kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <CAJZ5v0jo6q5mniU2HihHcOSqggZ8HFy3mtuo0vXYwuc2tLQ7=w@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 5:58 PM, Rafael J. Wysocki <rafael@kernel.org> wrote:
> On Mon, Aug 21, 2017 at 1:43 PM, Bhumika Goyal <bhumirks@gmail.com> wrote:
>> Make these const. Done using Coccinelle.
>>
>> @match disable optional_qualifier@
>> identifier s;
>> @@
>> static struct device_attribute s = {...};
>>
>> @ref@
>> position p;
>> identifier match.s;
>> @@
>> s@p
>>
>> @good1@
>> identifier match.s;
>> expression e1;
>> position ref.p;
>> @@
>> device_remove_file(e1,&s@p,...)
>>
>> @good2@
>> identifier match.s;
>> expression e1;
>> position ref.p;
>> @@
>> device_create_file(e1,&s@p,...)
>>
>>
>> @bad depends on  !good1 && !good2@
>> position ref.p;
>> identifier match.s;
>> @@
>> s@p
>>
>> @depends on forall !bad disable optional_qualifier@
>> identifier match.s;
>> @@
>> static
>> + const
>> struct device_attribute s;
>>
>> Bhumika Goyal (6):
>>   ACPI: make device_attribute const
>>   nbd: make device_attribute const
>>   hid: make device_attribute const
>>   qlogic:  make device_attribute const
>>   platform/x86: make device_attribute const
>>   power: supply: make device_attribute const
>
> It would be better to send these patches separately, because they
> touch code maintained by different people and I guess no one will take
> the whole series.
>
> I'll take care of the ACPI one, but the rest needs to go in via their
> proper trees.
>

Thanks for the note. From now onwards, I will send it separately
depending on the maintainers. But is possible please consider it this
time.

Thanks,
Bhumika

> Thanks,
> Rafael
