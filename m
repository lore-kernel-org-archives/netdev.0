From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: [PATCH v5 1/4] gpiolib: define gpio suffixes globally
Date: Wed, 11 Feb 2015 17:27:55 +0100
Message-ID: <13969625.rHfHuA5z02@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexandre Courbot <acourbot@nvidia.com>,
	Alexandre Courbot <gnurou@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid multiple identical definitions of the gpio suffix strings by putting
them into a global constant array.

Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>
---
Change log:
  v5: move the global definition to drivers/gpio/gpiolib.h
  v4: no change
  v3: add this change as a separate patch

 drivers/gpio/gpiolib.c | 14 ++++++--------
 drivers/gpio/gpiolib.h |  3 +++
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/gpio/gpiolib.c b/drivers/gpio/gpiolib.c
index bf6016d..b71c351 100644
--- a/drivers/gpio/gpiolib.c
+++ b/drivers/gpio/gpiolib.c
@@ -1657,19 +1657,18 @@ static struct gpio_desc *of_find_gpio(struct device *dev, const char *con_id,
 				      unsigned int idx,
 				      enum gpio_lookup_flags *flags)
 {
-	static const char * const suffixes[] = { "gpios", "gpio" };
 	char prop_name[32]; /* 32 is max size of property name */
 	enum of_gpio_flags of_flags;
 	struct gpio_desc *desc;
 	unsigned int i;
 
-	for (i = 0; i < ARRAY_SIZE(suffixes); i++) {
+	for (i = 0; i < ARRAY_SIZE(gpio_suffixes); i++) {
 		if (con_id)
 			snprintf(prop_name, sizeof(prop_name), "%s-%s", con_id,
-							       suffixes[i]);
+				 gpio_suffixes[i]);
 		else
 			snprintf(prop_name, sizeof(prop_name), "%s",
-							       suffixes[i]);
+				 gpio_suffixes[i]);
 
 		desc = of_get_named_gpiod_flags(dev->of_node, prop_name, idx,
 						&of_flags);
@@ -1690,7 +1689,6 @@ static struct gpio_desc *acpi_find_gpio(struct device *dev, const char *con_id,
 					unsigned int idx,
 					enum gpio_lookup_flags *flags)
 {
-	static const char * const suffixes[] = { "gpios", "gpio" };
 	struct acpi_device *adev = ACPI_COMPANION(dev);
 	struct acpi_gpio_info info;
 	struct gpio_desc *desc;
@@ -1698,13 +1696,13 @@ static struct gpio_desc *acpi_find_gpio(struct device *dev, const char *con_id,
 	int i;
 
 	/* Try first from _DSD */
-	for (i = 0; i < ARRAY_SIZE(suffixes); i++) {
+	for (i = 0; i < ARRAY_SIZE(gpio_suffixes); i++) {
 		if (con_id && strcmp(con_id, "gpios")) {
 			snprintf(propname, sizeof(propname), "%s-%s",
-				 con_id, suffixes[i]);
+				 con_id, gpio_suffixes[i]);
 		} else {
 			snprintf(propname, sizeof(propname), "%s",
-				 suffixes[i]);
+				 gpio_suffixes[i]);
 		}
 
 		desc = acpi_get_gpiod_by_index(adev, propname, idx, &info);
diff --git a/drivers/gpio/gpiolib.h b/drivers/gpio/gpiolib.h
index e3a5211..3cbf3dd 100644
--- a/drivers/gpio/gpiolib.h
+++ b/drivers/gpio/gpiolib.h
@@ -27,6 +27,9 @@ struct acpi_gpio_info {
 	bool active_low;
 };
 
+/* gpio suffixes used for ACPI and device tree lookup */
+static const char * const gpio_suffixes[] = { "gpios", "gpio" };
+
 #ifdef CONFIG_ACPI
 void acpi_gpiochip_add(struct gpio_chip *chip);
 void acpi_gpiochip_remove(struct gpio_chip *chip);
-- 
2.0.5


