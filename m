From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH net-next 1/2] wireless: Remove casts of
	void *
Date: Tue, 14 Jun 2011 15:39:32 +1000
Message-ID: <BANLkTik4fWbCc8pRZfKCzvKD2f6sK9QCEw@mail.gmail.com>
References: <cover.1308024069.git.joe@perches.com>
	<337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
	<BANLkTi=i30Rn7gpCDbn9KKJucq8CB=hssA@mail.gmail.com>
	<1308029532.26699.68.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Intel Linux Wireless <ilw@linux.intel.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	ath9k-devel@lists.ath9k.org, Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1308029532.26699.68.camel@Joe-Laptop>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Joe,

On Tue, Jun 14, 2011 at 15:32, Joe Perches <joe@perches.com> wrote:
> On Tue, 2011-06-14 at 15:23 +1000, Julian Calaby wrote:
>> Joe,
>
> Hi Julian.
>
>> On Tue, Jun 14, 2011 at 14:02, Joe Perches <joe@perches.com> wrote:
>> > Unnecessary casts of void * clutter the code.
>> > These are the remainder casts after several specific
>> > patches to remove netdev_priv and dev_priv.
>> You seem to have removed a lot of casts that don't relate to these clean=
ups.
>> In particular, some of the casts seem to relate more to documentation
>> rather than just changing pointer types to make the compiler happy.
>
> All of the cast removals are casts of void* types.
> I think none of of the casts are useful.
> None of them are required, all are duplicative.

My issue here is that you mention in the commit log that this relates
to the removal of netdev_priv and dev_priv, but the casts removed
(mostly) don't.

>> In
>> particular, I'm referring to the casts describing the different usages
>> of data_buf in mwiflex, and around some pointer math in ath9k.
>
> Can you describe more in detail why you think these are documentary?
>
> This sort of cast:
>
> diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mw=
ifiex/11n.c
> @@ -191,7 +191,7 @@ int mwifiex_ret_11n_cfg(struct host_cmd_ds_command *r=
esp, void *data_buf)
> =A0 =A0 =A0 =A0struct host_cmd_ds_11n_cfg *htcfg =3D &resp->params.htcfg;
>
> =A0 =A0 =A0 =A0if (data_buf) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_cfg =3D (struct mwifiex_ds_11n_tx_cfg *)=
 data_buf;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_cfg =3D data_buf;
>
> I think pretty useless. =A0tx_cfg is a struct mwifiex_ds_11n_tx_cfg *.

True, but IMHO, this documents, particularly in a random snippet like
this, what's going on. Arguably though, a better fix would be to move
the cast to the place where this function is called.

>> Whilst I'm sure that the compiler is smart enough to handle automatic
>> casts between pointer types, some of these, in particular the mwiflex
>> bits, add some documentation to the code.
>
> I think not. =A0Opinions of course can vary.

Of course. I rarely look at full files, so the more information that
can be stuffed into a patch, the better for me. That said, I agree
that all the casts removed are superfluous.

Thanks,

-- =

Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
