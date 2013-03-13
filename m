From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] ssb: pci: Fix flipping of MAC address
Date: Wed, 13 Mar 2013 14:14:25 -0500
Message-ID: <5140D011.8060701@lwfinger.net>
References: <513e40c2.MDaC+Q82iTl9PpIZ%Larry.Finger@lwfinger.net> <20130313181817.GB19917@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130313181817.GB19917-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/13/2013 01:18 PM, John W. Linville wrote:
> On Mon, Mar 11, 2013 at 03:38:26PM -0500, Larry Finger wrote:
>> Since commit e565275 entitled "ssb: pci: Standardize a function to g=
et mac
>> address", the SPROM readout of the MAC has had the values flipped so=
 that
>> 00:11:22:33:44:55 became 11:00:33:22:55:44. The fix has been tested =
on both
>> little- and big-endian architectures.
>>
>> Reported-by: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>> ---
>>
>> John,
>>
>> This bug was introduced in 3.9, and should be fixed there.
>>
>> Thanks,
>>
>> Larry
>> ---
>>
>> Index: wireless-testing-new/drivers/ssb/pci.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- wireless-testing-new.orig/drivers/ssb/pci.c
>> +++ wireless-testing-new/drivers/ssb/pci.c
>> @@ -234,8 +234,8 @@ static void sprom_get_mac(char *mac, con
>>   {
>>   	int i;
>>   	for (i =3D 0; i < 3; i++) {
>> -		*mac++ =3D in[i];
>>   		*mac++ =3D in[i] >> 8;
>> +		*mac++ =3D in[i];
>>   	}
>>   }
>
> Actually, FWIW it seems to have been introduced in commit
> e5652756ff36ed9e1283121f788e6a17117efcab, which is slated for 3.10.
> I'm happy to merge it in wireless-next.

After further checking, I agree that it is not in 3.9. As long as the f=
ix is=20
merged before 3.10, all will be OK.

Sorry for the confusion.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
