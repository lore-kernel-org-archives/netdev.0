From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v2 4/4] drivers: net: Add APM X-Gene SoC ethernet driver
 support.
Date: Mon, 14 Apr 2014 15:09:26 -0700
Message-ID: <CAKh23Fn2-P3QAntShpjBV027POgYfxmCFh3H3KZ5dSpUpa+4yQ@mail.gmail.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
 <1397271984-23405-5-git-send-email-isubramanian@apm.com>
 <20140412.165549.1068958710661824002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org, patches <patches@apm.com>,
 linux-kernel@vger.kernel.org, "jcm@redhat.com" <jcm@redhat.com>,
 Keyur Chudgar <kchudgar@apm.com>, linux-arm-kernel@lists.infradead.org,
 Ravi Patel <rapatel@apm.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140412.165549.1068958710661824002.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi David,

Thanks for the review comments.  Please find my responses inline.

Thanks,
Iyappan

On Sat, Apr 12, 2014 at 1:55 PM, David Miller <davem@davemloft.net> wrote:
> From: Iyappan Subramanian <isubramanian@apm.com>
> Date: Fri, 11 Apr 2014 20:06:24 -0700
>
>> This patch adds network driver for APM X-Gene SoC ethernet.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Signed-off-by: Ravi Patel <rapatel@apm.com>
>> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
>
> This driver is going to take a long to review and get to the point
> where it can be integrated upstream, I'm just trying to set your
> expectations properly.
Okay.
>
>> +inline void set_desc(struct xgene_enet_desc *desc, enum desc_info_index index,
>> +                  u64 val)
>> +{
>
> The "inline" tag is not necessary, let the compiler figure it out.
Okay.  I will remove inline keyword from the code.
>
>> +     u8 word_index = desc_info[index].word_index;
>> +     u8 start_bit = desc_info[index].start_bit;
>> +     u8 len = desc_info[index].len;
>> +
>> +     u64 mask = GENMASK_ULL((start_bit + len - 1), start_bit);
>> +     ((u64 *)desc)[word_index] = (((u64 *)desc)[word_index] & ~mask)
>> +         | (((u64) val << start_bit) & mask);
>
> This looks horrible for several reasons.
>
> First of all, do not put empty lines in the middle of a set of
> local variable declarations.
>
> But do put a single empty line after the last local variable, and
> before the actual code of the function starts.
>
> Get rid of all of this excessive casting.  Tell the compiler what you're
> actually doing, pass 'desc' in as "void *" and use local "u64 *" pointers
> (to which 'desc' is assigned to) if you must.
I will fix this in the next patch.
