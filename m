From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Macro definition for SFF-8436/8636
 Memory map max sizes
Date: Sat, 11 Jun 2016 15:51:34 -0700 (PDT)
Message-ID: <20160611.155134.1474324006340328110.davem@davemloft.net>
References: <1465278926-10231-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bwh@kernel.org, netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: vidya@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbcFKWvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 18:51:35 -0400
In-Reply-To: <1465278926-10231-1-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: vidya@cumulusnetworks.com
Date: Mon,  6 Jun 2016 22:55:26 -0700

> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> 
> This patch provides macro definitions for maximum possible
> memory map size of QSFP+/QSFP28 EEPROMs as per SFF-8436/SFF-8636
> 
> According to SFF-8436/SFF-8636 specs, the common memory map for
> managing external cable interfaces is arranged into a single
> lower page address space of 128 bytes and multiple upper address pages
> of 128 bytes each. The total size of memory map is up to 5 128 byte pages
> defined by a "pages valid" register and switched via a "page select"
> register for "optional pages". Memory of 256 bytes can be memory mapped
> at a time and QSFP+/QSFP28  drivers can export upto 5*128 bytes of
> eeprom dump.
> 
> QSFP+/QSFP28 Memory layout
>            2-Wire Serial Address: 1010000x
>            Lower Page 00h (128 bytes)
>            ======================
>            |Page Select Byte(127)|
>            ======================
>                     |
>                     V
>        ----------------------------------------
>       |             |            |             |
>       V             V            V             V
>    ----------   ----------   ---------    ------------
>   | Upper    | | Upper    | | Upper    | | Upper      |
>   | Page 00h | | Page 01h | | Page 02h | | Page 03h   |
>   |          | |(Optional)| |(Optional)| | (Optional) |
>   |    ID    | |   AST    | |  User    | |  For       |
>   |  Fields  | |  Table   | | EEPROM   | |  Cable     |
>   -----------  -----------   ----------  --------------
> 
> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Why do we need these values in the header file at all?

The application can probe the size by repeated eeprom calls, increasing
the buffer size each time as needed until success.
