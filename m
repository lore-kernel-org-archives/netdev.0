From: Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH 1/2] Bluetooth: Add reset_resume function
Date: Tue, 2 Jun 2015 10:17:27 -0400
Message-ID: <CA+5PVA6o2=dF5BrJQojhMjJhsAiM9vaADd_ix3SAvVEbLXkjCQ@mail.gmail.com>
References: <1433207682-15064-1-git-send-email-labbott@fedoraproject.org>
	<BB3BCC01-8BF0-4A17-B8E6-F17B875F1997@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BB3BCC01-8BF0-4A17-B8E6-F17B875F1997-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 1, 2015 at 9:28 PM, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> wrote:
> Hi Laura,
>
>> Bluetooth devices off of some buses such as USB may lose power across
>> suspend/resume. When this happens, drivers may need to have the setup
>> function called again and behave differently than a cold power on.
>> Add a reset_resume function for drivers to call. During the
>> reset_resume case, the flag HCI_RESET_RESUME will be set to allow
>> drivers to differentate.
>>
>> Signed-off-by: Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
>> ---
>> This matches with what hci_reset_dev does and also ensures
>> the setup function gets called again.
>> ---
>> include/net/bluetooth/hci.h      |  1 +
>> include/net/bluetooth/hci_core.h |  1 +
>> net/bluetooth/hci_core.c         | 16 ++++++++++++++++
>> 3 files changed, 18 insertions(+)
>>
>> diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
>> index d95da83..6285410 100644
>> --- a/include/net/bluetooth/hci.h
>> +++ b/include/net/bluetooth/hci.h
>> @@ -185,6 +185,7 @@ enum {
>>       HCI_RAW,
>>
>>       HCI_RESET,
>> +     HCI_RESET_RESUME,
>> };
>
> no more addition to this list of flags please. These are userspace exposed flags and with that ABI that we are never ever touching again. If you need flags on a per device basis, then use the second list.

It would be helpful for other developers if you added a comment to
that effect above the enum definition.  Otherwise you're going to wind
up repeating yourself over time.

Also, if they're exposed to userspace, should this file be using the
uapi mechanism?  I'm confused how they're exposed today, given that
they aren't installed via 'make headers_install'.  Is this manually
synced with some other .h file in a userspace package?

josh
