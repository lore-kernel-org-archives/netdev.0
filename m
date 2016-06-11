From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ethtool: Macro definition for SFF-8436/8636
 Memory map max sizes
Date: Sat, 11 Jun 2016 16:22:38 -0700
Message-ID: <CAKWE-Xrw6kE7-rSOP1NRQaT3jAHWVVkhWz8c2oinYmQc+LrnjQ@mail.gmail.com>
References: <1465278926-10231-1-git-send-email-vidya@cumulusnetworks.com>
	<20160611.155134.1474324006340328110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bwh@kernel.org, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:35798 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbcFKXWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 19:22:39 -0400
Received: by mail-yw0-f182.google.com with SMTP id z186so79604705ywd.2
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2016 16:22:39 -0700 (PDT)
In-Reply-To: <20160611.155134.1474324006340328110.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2016 at 3:51 PM, David Miller <davem@davemloft.net> wrote:
> From: vidya@cumulusnetworks.com
> Date: Mon,  6 Jun 2016 22:55:26 -0700
>
>> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>>
>> This patch provides macro definitions for maximum possible
>> memory map size of QSFP+/QSFP28 EEPROMs as per SFF-8436/SFF-8636
>>
>> According to SFF-8436/SFF-8636 specs, the common memory map for
>> managing external cable interfaces is arranged into a single
>> lower page address space of 128 bytes and multiple upper address pages
>> of 128 bytes each. The total size of memory map is up to 5 128 byte pages
>> defined by a "pages valid" register and switched via a "page select"
>> register for "optional pages". Memory of 256 bytes can be memory mapped
>> at a time and QSFP+/QSFP28  drivers can export upto 5*128 bytes of
>> eeprom dump.
>>
>> QSFP+/QSFP28 Memory layout
>>            2-Wire Serial Address: 1010000x
>>            Lower Page 00h (128 bytes)
>>            ======================
>>            |Page Select Byte(127)|
>>            ======================
>>                     |
>>                     V
>>        ----------------------------------------
>>       |             |            |             |
>>       V             V            V             V
>>    ----------   ----------   ---------    ------------
>>   | Upper    | | Upper    | | Upper    | | Upper      |
>>   | Page 00h | | Page 01h | | Page 02h | | Page 03h   |
>>   |          | |(Optional)| |(Optional)| | (Optional) |
>>   |    ID    | |   AST    | |  User    | |  For       |
>>   |  Fields  | |  Table   | | EEPROM   | |  Cable     |
>>   -----------  -----------   ----------  --------------
>>
>> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>
> Why do we need these values in the header file at all?

As part of ethtool application, application is requesting  the drivers
to provide the supported eeprom size to allocate memory buffer for
getting complete dump.

In case of QSFP+/QSFP28, the size can be either 256 or 640 bytes(when
optional pages are supported) and it would be good to have same macros
across ethtool application and ethernet drivers for providing
eeprom_length field in  ETHTOOL_GMODULEINFO ioctl .


>
> The application can probe the size by repeated eeprom calls, increasing
> the buffer size each time as needed until success.
