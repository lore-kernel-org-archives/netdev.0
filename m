From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 11/31] Constify struct file_operations for 2.6.32 v1
Date: Sat, 05 Dec 2009 03:50:23 +0100
Message-ID: <4B19CA6F.4090700@gmail.com>
References: <4B198670.2000406@gmail.com> <4B198C43.50205@gmail.com> <4B19A333.5080103@gmail.com> <20091205000942.GA8224@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lenb@kernel.org, astarikovskiy@suse.de, mchehab@infradead.org,
	linville@tuxdriver.com, miklos@szeredi.hu, davem@davemloft.net,
	rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com,
	avi@redhat.com, mtosatti@redhat.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34981 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754262AbZLECta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 21:49:30 -0500
In-Reply-To: <20091205000942.GA8224@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> On Sat, Dec 05, 2009 at 01:02:59AM +0100, Emese Revfy wrote:
>> From: Emese Revfy <re.emese@gmail.com>
>>
>> Constify struct file_operations with some exceptions.
>> Per Dave Miller's suggestion, resend with proper CC list and patch format.
>>
>> Signed-off-by: Emese Revfy <re.emese@gmail.com>
>> ---
>>  drivers/acpi/battery.c                           |    2 +-
>>  drivers/char/pty.c                               |   16 +++++++++---
>>  drivers/char/tty_io.c                            |   28 ++++-----------------
>>  drivers/media/dvb/dvb-core/dvbdev.c              |    1 +
>>  drivers/net/wireless/b43/debugfs.c               |    2 +-
>>  drivers/net/wireless/b43legacy/debugfs.c         |    2 +-
>>  drivers/net/wireless/libertas/debugfs.c          |    2 +-
>>  drivers/staging/b3dfg/b3dfg.c                    |    2 +-
>>  drivers/staging/dream/qdsp5/adsp_driver.c        |    2 +-
>>  drivers/staging/dream/qdsp5/audio_aac.c          |    2 +-
>>  drivers/staging/dream/qdsp5/audio_amrnb.c        |    2 +-
>>  drivers/staging/dream/qdsp5/audio_evrc.c         |    2 +-
>>  drivers/staging/dream/qdsp5/audio_in.c           |    4 +-
>>  drivers/staging/dream/qdsp5/audio_mp3.c          |    2 +-
>>  drivers/staging/dream/qdsp5/audio_out.c          |    4 +-
>>  drivers/staging/dream/qdsp5/audio_qcelp.c        |    2 +-
>>  drivers/staging/dream/qdsp5/snd.c                |    2 +-
>>  drivers/staging/dream/smd/smd_qmi.c              |    2 +-
>>  drivers/staging/dream/smd/smd_rpcrouter_device.c |    4 +-
>>  drivers/staging/panel/panel.c                    |    4 +-
>>  drivers/staging/poch/poch.c                      |    2 +-
>>  drivers/staging/sep/sep_driver.c                 |    2 +-
>>  drivers/staging/vme/devices/vme_user.c           |    2 +-
>>  fs/fuse/cuse.c                                   |   20 +++++++++------
>>  fs/fuse/dev.c                                    |    8 +++---
>>  fs/fuse/fuse_i.h                                 |   10 ++++++++
>>  include/linux/tty.h                              |   14 ++++++++++-
>>  include/net/tcp.h                                |    1 +
>>  include/net/udp.h                                |    1 +
>>  kernel/trace/trace_events.c                      |    2 +
>>  virt/kvm/kvm_main.c                              |    3 ++
>>  31 files changed, 89 insertions(+), 63 deletions(-)
>>
>> diff --git a/drivers/acpi/battery.c b/drivers/acpi/battery.c
>> index 3f4602b..2e41d36 100644
>> --- a/drivers/acpi/battery.c
>> +++ b/drivers/acpi/battery.c
>> @@ -763,7 +763,7 @@ DECLARE_FILE_FUNCTIONS(alarm);
>>  	}
>>  
>>  static struct battery_file {
>> -	struct file_operations ops;
>> +	const struct file_operations ops;
>>  	mode_t mode;
>>  	const char *name;
>>  } acpi_battery_file[] = {
>> diff --git a/drivers/char/pty.c b/drivers/char/pty.c
>> index 62f282e..d39c67b 100644
>> --- a/drivers/char/pty.c
>> +++ b/drivers/char/pty.c
>> @@ -682,7 +682,18 @@ static int ptmx_open(struct inode *inode, struct file *filp)
>>  	return ret;
>>  }
>>  
>> -static struct file_operations ptmx_fops;
>> +static const struct file_operations ptmx_fops = {
>> +	.llseek		= no_llseek,
>> +	.read		= tty_read,
>> +	.write		= tty_write,
>> +	.poll		= tty_poll,
>> +	.unlocked_ioctl	= tty_ioctl,
>> +	.compat_ioctl	= tty_compat_ioctl,
>> +	.open		= ptmx_open,
>> +	.release	= tty_release,
>> +	.fasync		= tty_fasync,
>> +};
> 
> You just made these functions all global, for no real good reason.  Why
> did you do this?
> 
> confused,
> 
> greg k-h

I think this is the only way to make ptmx_fops const, provided we want to. 
--
Emese
