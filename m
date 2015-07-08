From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: add write access to debugfs
 regs file
Date: Wed, 8 Jul 2015 17:12:59 -0400 (EDT)
Message-ID: <268315096.110637.1436389979563.JavaMail.zimbra@savoirfairelinux.com>
References: <1436387779-23407-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150708205348.GH1357@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:65481 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758556AbbGHVNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:13:04 -0400
In-Reply-To: <20150708205348.GH1357@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

----- On Jul 8, 2015, at 4:53 PM, Andrew Lunn andrew@lunn.ch wrote:

> On Wed, Jul 08, 2015 at 04:36:18PM -0400, Vivien Didelot wrote:
>> Allow write access to the regs file in the debugfs interface, with the
>> following parameters:
>> 
>>     echo <name> <reg> <value> > regs
>> 
>> Where "name" is the register name (as shown in the header row), "reg" is
>> the register address (as shown in the first column) and "value" is the
>> 16-bit value. e.g.:
>> 
>>     echo GLOBAL 1a 5550 > regs
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  drivers/net/dsa/mv88e6xxx.c | 32 +++++++++++++++++++++++++++++++-
>>  1 file changed, 31 insertions(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
>> index 8c130c0..04e6eb6 100644
>> --- a/drivers/net/dsa/mv88e6xxx.c
>> +++ b/drivers/net/dsa/mv88e6xxx.c
>> @@ -1648,6 +1648,35 @@ static int mv88e6xxx_regs_show(struct seq_file *s, void
>> *p)
>>  	return 0;
>>  }
>>  
>> +static ssize_t mv88e6xxx_regs_write(struct file *file, const char __user *buf,
>> +				    size_t count, loff_t *ppos)
>> +{
>> +	struct seq_file *s = file->private_data;
>> +	struct dsa_switch *ds = s->private;
>> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>> +	char name[count];
> 
> Is this safe? Is count somehow limited? If i was to echo 8K to the
> file would i not exceed the kernel stack space?
> 
>      Andrew

I thought it was. But maybe 32 is a better value here. I'll resend these
two patches with char name[32] instead, tomorrow.

Thanks for your time,
-v
