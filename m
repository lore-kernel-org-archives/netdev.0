From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] lib: fix callers of strtobool to use char array
Date: Wed, 27 Jan 2016 17:03:23 -0800
Message-ID: <CAGXu5jKhTDX_JcEgO=kVfb-LRdPAfoRtiYXTHJLT_ABTt3MY6g@mail.gmail.com>
References: <20160128004542.GA15247@www.outflux.net>
	<1453942708.10099.41.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-cifs@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453942708.10099.41.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 27, 2016 at 4:58 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2016-01-27 at 16:45 -0800, Kees Cook wrote:
>> Some callers of strtobool were passing a pointer to unterminated strings.
>> This fixes the issue and consolidates some logic in cifs.
>
> This may be incomplete as it duplicates the behavior for
> the old number of characters, but this is not a solution
> for the entry of a bool that is "on" or "off".

As in, the on/off patch is missing? Yes, that's been sent separately,
but I wanted to make sure these changes weren't upsetting to the two
users.

>> diff --git a/fs/cifs/cifs_debug.c b/fs/cifs/cifs_debug.c
> []
>> @@ -290,7 +305,8 @@ static ssize_t cifs_stats_proc_write(struct file *file,
>>                       }
>>               }
>>               spin_unlock(&cifs_tcp_ses_lock);
>> -     }
>> +     } else
>> +             return rc;
>
> Likely better to reverse the test and unindent the
> preceding block.
>
> Otherwise, please make sure to use the general brace
> form of when one branch needs braces, the other branch
> should have them too.

Okay, sure, I'll rework this and send it together with the on/off patch.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
