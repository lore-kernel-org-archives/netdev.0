From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: wireless: brcm80211: brcmfmac: dhd_sdio.c: Cleaning
 up missing null-terminate in conjunction with strncpy
Date: Mon, 13 Oct 2014 22:14:07 +0200
Message-ID: <CAFo99gZxFcTcXQnutcYt7o8aCXNRQT-aBQ6C=V4ZsK=7aUiX=w@mail.gmail.com>
References: <1413071551-15372-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
 <063D6719AE5E284EB5DD2968C1650D6D174C992F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"brcm80211-dev-list@broadcom.com" <brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C992F@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-10-13 10:55 GMT+02:00 David Laight <David.Laight@aculab.com>:
> From: Rickard Strandqvist
>> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
>> And changed from using strncpy to strlcpy to simplify code.
>
> I think you should return an error if the strings get truncated.
> Silent truncation is going to lead to issues at some point in the future
> (in some places).
>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>> ---
>>  drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   25 ++++++++++----------
>>  1 file changed, 12 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>> b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>> index f55f625..d20d4e6 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>> @@ -670,7 +670,6 @@ static int brcmf_sdio_get_fwnames(struct brcmf_chip *ci,
>>                                 struct brcmf_sdio_dev *sdiodev)
>>  {
>>       int i;
>> -     uint fw_len, nv_len;
>>       char end;
>>
>>       for (i = 0; i < ARRAY_SIZE(brcmf_fwname_data); i++) {
>> @@ -684,25 +683,25 @@ static int brcmf_sdio_get_fwnames(struct brcmf_chip *ci,
>>               return -ENODEV;
>>       }
>>
>> -     fw_len = sizeof(sdiodev->fw_name) - 1;
>> -     nv_len = sizeof(sdiodev->nvram_name) - 1;
>>       /* check if firmware path is provided by module parameter */
>>       if (brcmf_firmware_path[0] != '\0') {
>> -             strncpy(sdiodev->fw_name, brcmf_firmware_path, fw_len);
>> -             strncpy(sdiodev->nvram_name, brcmf_firmware_path, nv_len);
>> -             fw_len -= strlen(sdiodev->fw_name);
>> -             nv_len -= strlen(sdiodev->nvram_name);
>> +             strlcpy(sdiodev->fw_name, brcmf_firmware_path,
>> +                     sizeof(sdiodev->fw_name));
>> +             strlcpy(sdiodev->nvram_name, brcmf_firmware_path,
>> +                     sizeof(sdiodev->nvram_name));
>>
>>               end = brcmf_firmware_path[strlen(brcmf_firmware_path) - 1];
>
> If you are doing a strlen() here, you could use the length for the copy
> and/or use it to avoid the strcat().
>
>>               if (end != '/') {
>> -                     strncat(sdiodev->fw_name, "/", fw_len);
>> -                     strncat(sdiodev->nvram_name, "/", nv_len);
>> -                     fw_len--;
>> -                     nv_len--;
>> +                     strlcat(sdiodev->fw_name, "/",
>> +                             sizeof(sdiodev->fw_name));
>> +                     strlcat(sdiodev->nvram_name, "/",
>> +                             sizeof(sdiodev->nvram_name));
>>               }
>>       }
>> -     strncat(sdiodev->fw_name, brcmf_fwname_data[i].bin, fw_len);
>> -     strncat(sdiodev->nvram_name, brcmf_fwname_data[i].nv, nv_len);
>> +     strlcat(sdiodev->fw_name, brcmf_fwname_data[i].bin,
>> +             sizeof(sdiodev->fw_name));
>> +     strlcat(sdiodev->nvram_name, brcmf_fwname_data[i].nv,
>> +             sizeof(sdiodev->nvram_name));
>
> I assume something ensures that fw_name[0] == 0 here.
>
>         David


Hi David


What do you mean you would use the strlen, can you give some example
code instead?


Arend van Spriel wanted me to change the title before.
So this should really continue the conversation in that new mail. And
then you can also see my other comments.
And I have the same type of objection to the:
brcmf_firmware_path[0] == '\0'

Se:
https://lkml.org/lkml/2014/10/12/42

Kind regards
Rickard Strandqvist
