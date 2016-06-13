From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [PATCH 1/2] add basic register-field manipulation macros
Date: Mon, 13 Jun 2016 15:32:48 +0200
Message-ID: <6d30cb55-6840-c575-7bc9-579cd8ed7e68@nbd.name>
References: <1465824594-29662-1-git-send-email-jakub.kicinski@netronome.com>
 <1465824594-29662-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, linux-kernel@vger.kernel.org,
	kvalo@codeaurora.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465824594-29662-2-git-send-email-jakub.kicinski@netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-06-13 15:29, Jakub Kicinski wrote:
> C bitfields are problematic and best avoided.  Developers
> interacting with hardware registers find themselves searching
> for easy-to-use alternatives.  Common approach is to define
> structures or sets of macros containing mask and shift pair.
> Operations on the register are then performed as follows:
> 
>  field = (reg >> shift) & mask;
> 
>  reg &= ~(mask << shift);
>  reg |= (field & mask) << shift;
> 
> Defining shift and mask separately is tedious.  Ivo van Doorn
> came up with an idea of computing them at compilation time
> based on a single shifted mask (later refined by Felix) which
> can be used like this:
> 
>  #define X_REG_FIELD 0x000ff000
> 
>  field = FIELD_GET(X_REG_FIELD, reg);
> 
>  reg &= ~X_REG_FIELD;
>  reg |= FIELD_PUT(X_REG_FIELD, field);
> 
> FIELD_{GET,PUT} macros take care of finding out what the
> appropriate shift is based on compilation time ffs operation.
> 
> GENMASK can be used to define registers (which is usually
> less error-prone and easier to match with datasheets).
> 
> This approach is the most convenient I've seen so to limit code
> multiplication let's move the macros to a global header file.
> 
> Compared to Felix Fietkau's implementation from mt76 this one
> uses standard Linux and GCC functions such as is_power_of_2()
> and __builtin_ffsll().
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  include/linux/bitfield.h | 58 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/log2.h     |  6 +++++
>  2 files changed, 64 insertions(+)
>  create mode 100644 include/linux/bitfield.h
> 
> diff --git a/include/linux/bitfield.h b/include/linux/bitfield.h
> new file mode 100644
> index 000000000000..ae2224464523
> --- /dev/null
> +++ b/include/linux/bitfield.h
> @@ -0,0 +1,58 @@
> +/*
> + * Copyright (C) 2014 Felix Fietkau <nbd@openwrt.org>
Please change my email address to nbd@nbd.name here

- Felix
