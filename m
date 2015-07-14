From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH] iwlwifi: Deinline iwl_{read,write}{8,32}
Date: Tue, 14 Jul 2015 14:41:54 +0200
Message-ID: <CAK1hOcPvb3mOeVm5HMqSCKAyJv47HturM+C9uxvA1=KWn94dtw@mail.gmail.com>
References: <1436876558-6674-1-git-send-email-dvlasenk@redhat.com> <55A502B6.5090806@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Johannes Berg <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A502B6.5090806@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2015 at 2:38 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
>> +#define IWL_READ_WRITE(static_inline) \
>> +static_inline void iwl_write8(struct iwl_trans *trans, u32 ofs, u8 val) \
>> +{ \
>> +       trace_iwlwifi_dev_iowrite8(trans->dev, ofs, val); \
>> +       iwl_trans_write8(trans, ofs, val); \
>> +} \
> [...]
>>
>> +#if !defined(CONFIG_IWLWIFI_DEVICE_TRACING)
>> +IWL_READ_WRITE(static inline)
>
>    Not static_inline?

Yes. Here we are putting two words, "static inline", in front of every
function definition.
